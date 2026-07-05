# HomeHub Client Deployment

## Требования

На сервере должны быть установлены:

* Docker
* Docker Compose (`docker compose`)
* GitHub Actions Self-hosted Runner

---

# Первоначальная настройка сервера

## 1. Установить Docker

Проверить:

```bash
docker --version
docker compose version
```

---

## 2. Установить GitHub Actions Runner

Создать Runner для репозитория и зарегистрировать его.

После установки рекомендуется запускать его как сервис:

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

Проверить статус:

```bash
sudo ./svc.sh status
```

---

## 3. Настроить группу безопасности (Cloud Firewall)

Необходимо разрешить входящие подключения:

| Порт | Протокол | Источник                |
| ---- | -------- | ----------------------- |
| 22   | TCP      | свой IP или `0.0.0.0/0` |
| 80   | TCP      | `0.0.0.0/0`             |
| 443  | TCP      | `0.0.0.0/0`             |

После изменения правил может потребоваться несколько минут, пока они применятся к виртуальной машине.

---

## 4. Проверить Firewall Linux

Ubuntu:

```bash
sudo ufw status
```

Если используется UFW, открыть порты:

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

Если статус:

```text
Status: inactive
```

то дополнительная настройка не требуется.

---

# Развертывание

Деплой выполняется автоматически после Push в ветку `develop`.

Workflow GitHub Actions:

1. Получает актуальный код.
2. Собирает Docker-образ.
3. Перезапускает контейнер.
4. Очищает неиспользуемые Docker-образы.

---

# Проверка после деплоя

## Проверить контейнер

```bash
docker ps
```

Ожидается:

```text
homehub-client
0.0.0.0:80->80/tcp
```

---

## Проверить опубликованные порты

```bash
docker port homehub-client
```

---

## Проверить логи контейнера

```bash
docker logs homehub-client
```

---

## Проверить работу сайта локально на сервере

```bash
curl http://localhost
```

Должен вернуться HTML приложения.

---

## Проверить, кто слушает порт 80

```bash
sudo ss -tlnp | grep :80
```

---

## Проверить доменное имя

```bash
nslookup home.greefob.ru
```

или

```bash
ping home.greefob.ru
```

IP должен совпадать с IP виртуальной машины.

---

# Типичные проблемы

## Контейнер не запускается

Проверить:

```bash
docker ps -a
docker logs homehub-client
```

---

## Порт недоступен извне

Проверить:

* группу безопасности;
* Firewall Linux;
* публикацию порта Docker (`docker port`);
* DNS.

---

## GitHub Actions зависает на Waiting for a runner

Runner не запущен.

Проверить:

```bash
sudo ./svc.sh status
```

или

```bash
./run.sh
```

---

## Сборка Docker завершается ошибкой

Посмотреть полный лог GitHub Actions.

Наиболее частые причины:

* неверный путь в Dockerfile;
* ошибка `npm run build`;
* отсутствует каталог сборки (`build` или `dist`).

---

## Проверить состояние Docker

```bash
docker ps
docker images
docker volume ls
docker network ls
```

---

## Освободить место

Удалить неиспользуемые образы:

```bash
docker image prune -f
```

Удалить неиспользуемые контейнеры:

```bash
docker container prune -f
```

Удалить всё неиспользуемое:

```bash
docker system prune
```

---

# Будущая архитектура

На текущем этапе контейнер самостоятельно обслуживает HTTP.

В дальнейшем планируется выделить отдельный Reverse Proxy, который будет принимать HTTPS-трафик и распределять запросы между сервисами:

* HomeHub Client
* API Gateway
* другие сервисы инфраструктуры

Сертификаты будут храниться отдельно и подключаться через Docker Volumes.
