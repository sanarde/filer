#include "ThumbnailProvider.h"

#include "ThumbnailCache.h"
#include "Thumbnailers.h"

#include <QFileInfo>
#include <QImage>
#include <QImageReader>
#include <QQuickTextureFactory>
#include <QRunnable>
#include <QThreadPool>
#include <QMutex>
#include <QSet>
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
        const int edge = m_requestedSize.isValid() ? qMax(m_requestedSize.width(), m_requestedSize.height()) : 256;
        const int size = ThumbnailCache::sizeClass(edge);

        QImage image = ThumbnailCache::load(m_path, size);
        QString error;
        if (image.isNull())
            image = render(size, error);
        emit done(image, image.isNull() ? error : QString());
    }

signals:
    void done(const QImage &image, const QString &error);

private:
    QImage render(int size, QString &error)
    {
        QImageReader reader(m_path);
        reader.setAutoTransform(true);
        if (reader.canRead()) {
            const QSize original = reader.size();
            const bool large = original.width() > size || original.height() > size;
            if (large)
                reader.setScaledSize(original.scaled(size, size, Qt::KeepAspectRatio));
            const QImage image = reader.read();
            if (image.isNull())
                error = reader.errorString();
            else if (large)
                ThumbnailCache::store(m_path, size, image);
            return image;
        }

        const QString key = m_path + u'|' + QString::number(QFileInfo(m_path).lastModified().toSecsSinceEpoch());
        {
            QMutexLocker locker(&failedMutex);
            if (failed.contains(key)) {
                error = "no thumbnail";
                return QImage();
            }
        }

        QImage image = Thumbnailers::generate(m_path, size);
        if (image.isNull()) {
            QMutexLocker locker(&failedMutex);
            failed.insert(key);
            error = "no thumbnail";
            return image;
        }
        if (image.width() > size || image.height() > size)
            image = image.scaled(size, size, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        ThumbnailCache::store(m_path, size, image);
        return image;
    }

    static inline QMutex failedMutex;
    static inline QSet<QString> failed;

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
