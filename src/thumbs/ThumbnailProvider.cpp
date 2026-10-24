#include "ThumbnailProvider.h"

#include <QImage>
#include <QImageReader>
#include <QQuickTextureFactory>
#include <QRunnable>
#include <QThreadPool>
#include <QUrl>

class ThumbnailTask : public QObject, public QRunnable
{
    Q_OBJECT

public:
    ThumbnailTask(const QString &path, const QSize &requestedSize)
        : m_path(path)
        , m_requestedSize(requestedSize)
    {
    }

    void run() override
    {
        QImageReader reader(m_path);
        reader.setAutoTransform(true);

        const QSize original = reader.size();
        if (original.isValid() && m_requestedSize.isValid()
            && (original.width() > m_requestedSize.width()
                || original.height() > m_requestedSize.height())) {
            reader.setScaledSize(original.scaled(m_requestedSize, Qt::KeepAspectRatioByExpanding));
        }

        QImage image = reader.read();
        emit done(image, image.isNull() ? reader.errorString() : QString());
    }

signals:
    void done(const QImage &image, const QString &error);

private:
    QString m_path;
    QSize m_requestedSize;
};

class ThumbnailResponse : public QQuickImageResponse
{
    Q_OBJECT

public:
    ThumbnailResponse(const QString &path, const QSize &requestedSize)
    {
        auto *task = new ThumbnailTask(path, requestedSize);
        connect(task, &ThumbnailTask::done, this, &ThumbnailResponse::handleDone,
                Qt::QueuedConnection);
        QThreadPool::globalInstance()->start(task);
    }

    QQuickTextureFactory *textureFactory() const override
    {
        return QQuickTextureFactory::textureFactoryForImage(m_image);
    }

    QString errorString() const override { return m_error; }

private slots:
    void handleDone(const QImage &image, const QString &error)
    {
        m_image = image;
        m_error = error;
        emit finished();
    }

private:
    QImage m_image;
    QString m_error;
};

QQuickImageResponse *ThumbnailProvider::requestImageResponse(const QString &id,
                                                             const QSize &requestedSize)
{
    return new ThumbnailResponse(QUrl::fromPercentEncoding(id.toUtf8()), requestedSize);
}

#include "ThumbnailProvider.moc"
