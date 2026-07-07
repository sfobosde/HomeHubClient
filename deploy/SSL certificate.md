# Перевыпуск SSL-сертификата Let's Encrypt для `home.greefob.ru`

## Предварительные условия

Перед выпуском или перевыпуском сертификата:

- DNS-запись `home.greefob.ru` должна указывать на текущий сервер.
- Порт **80** должен быть доступен из интернета.
- На время выпуска сертификата порт **80** должен быть свободен.

Останавливаем фронтенд:

```bash
docker compose down
```

---

# Выпуск (или перевыпуск) сертификата

Если сертификат выпускается впервые:

```bash
sudo certbot certonly --standalone -d home.greefob.ru
```

Если сертификат уже существует и требуется перевыпуск:

```bash
sudo certbot certonly --standalone --force-renewal -d home.greefob.ru
```

После успешного выполнения сертификаты будут находиться в:

```text
/etc/letsencrypt/live/home.greefob.ru/
```

Фактические файлы располагаются в:

```text
/etc/letsencrypt/archive/home.greefob.ru/
```

---

# Проверка сертификатов

Проверяем наличие файлов:

```bash
sudo ls -l /etc/letsencrypt/live/home.greefob.ru
```

Ожидаемый результат:

```text
cert.pem
chain.pem
fullchain.pem
privkey.pem
```

Проверяем реальные файлы:

```bash
sudo ls -l /etc/letsencrypt/archive/home.greefob.ru
```

---

# Проверка срока действия сертификата

```bash
sudo openssl x509 \
    -in /etc/letsencrypt/live/home.greefob.ru/cert.pem \
    -noout -dates
```

Пример:

```text
notBefore=Jul  7 18:24:47 2026 GMT
notAfter=Oct  5 18:24:46 2026 GMT
```

---

# Копирование сертификатов для Docker

> Docker установлен через Snap, поэтому контейнер не имеет корректного доступа к `/etc/letsencrypt`.
>
> Для использования сертификатов в контейнере они копируются в домашнюю директорию пользователя.

Создаем каталог:

```bash
mkdir -p ~/certs
```

Копируем сертификаты:

```bash
sudo cp /etc/letsencrypt/archive/home.greefob.ru/fullchain1.pem ~/certs/fullchain.pem
sudo cp /etc/letsencrypt/archive/home.greefob.ru/privkey1.pem ~/certs/privkey.pem
```

Меняем владельца:

```bash
sudo chown $USER:$USER ~/certs/*
```

Проверяем:

```bash
ls -l ~/certs
```

Ожидаемый результат:

```text
fullchain.pem
privkey.pem
```

---

# Docker Compose

```yaml
volumes:
  - /home/user1/certs:/certs:ro
```

---

# Конфигурация nginx

```nginx
server {
    listen 443 ssl;
    http2 on;

    server_name home.greefob.ru;

    ssl_certificate     /certs/fullchain.pem;
    ssl_certificate_key /certs/privkey.pem;

    ...
}
```

---

# Запуск приложения

```bash
docker compose up -d --build
```

---

# Проверка HTTPS

Проверяем сертификат:

```bash
curl -Iv https://home.greefob.ru
```

Проверяем сайт в браузере:

```text
https://home.greefob.ru
```

---

# Обновление сертификата

Let's Encrypt выпускает сертификаты сроком на **90 дней**.

При каждом обновлении необходимо повторить только следующие шаги:

1. Выпустить (или обновить) сертификат:

```bash
sudo certbot certonly --standalone --force-renewal -d home.greefob.ru
```

2. Скопировать новые файлы:

```bash
sudo cp /etc/letsencrypt/archive/home.greefob.ru/fullchain*.pem ~/certs/fullchain.pem
sudo cp /etc/letsencrypt/archive/home.greefob.ru/privkey*.pem ~/certs/privkey.pem
sudo chown $USER:$USER ~/certs/*
```

3. Перезапустить контейнер:

```bash
docker compose restart homehub-client
```