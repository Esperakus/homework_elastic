# Домашняя работа "Централизованный сбор логов в кластер Elasticsearch"

Цель работы - настроить сбор логов веб-проекта в кластер ELK.

В качестве веб-проекта взята домашняя работа "Настройка конфигурации веб приложения под высокую нагрузку" (https://github.com/Esperakus/homework_web-hl)

Данный репозиторий содержит:

- Манифесты terraform для создания инфраструктуры проекта:
  - штатный балансировщик yandex.cloud, который будет проводить периодически health-check воркеров nginx и балансировать входящий трафик между ними
  - 2 воркера nginx, которые в свою очередь настроены на балансировку трафика на бэкенды веб приложения
  - 2 воркера бэкенда, на которых в systemd запущено простейшее приложение на go, слушающее порт 8090. При запросе отдаёт имя бэкенда (чтобы понять, на какой бэкенд прилетел запрос из Nginx) и версию БД
  - 1 iscsi target, раздающий диск в бэкенды
  - 1 экземпляр БД Postgresql 13 c базой test и пользователем БД test, чтоб принимать запросы от бэкенда
  - три ноды кластера Elasticsearch
  - 1 экземпляр kibana + logstash с внешним ip
  - и, наконец, виртуалка с установленным ансиблем для автоматизации разворачивания ролей. Выступает также в роли Jump host проекта.

Схема проекта:
![alt text](https://github.com/Esperakus/homework_elastic/blob/main/pics/pic3.png)

Для разворачивания проекта необходимо:

1. Заполнить значение переменных cloud_id, folder_id и iam-token в файле **variables.tf**.

2. Инициализировать рабочую среду Terraform:

```
$ terraform init
```
В результате будет установлен провайдер для подключения к облаку Яндекс.

3. Запустить разворачивание стенда:
```
$ terraform apply
```
В выходных данных будут показаны все внешние и внутренни ip адреса. 

```
# Пример вывода terraform apply:

Apply complete! Resources: 22 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_ansible = [
  "158.160.121.59",
]
external_ip_address_kibana = [
  "158.160.115.67",
]
...
```
Через некоторое время можно зайти на адреса http://{external_ip_address_kibana}:5601/app/observability/overview и http://{external_ip_address_kibana}:5601/app/logs/stream и увидеть, что  производится сбор логов всех узлов проекта с помощью filebeat.


Примеры того как выглядят собранные логи в кибане:
![alt text](https://github.com/Esperakus/homework_elastic/blob/main/pics/pic2.png)
![alt text](https://github.com/Esperakus/homework_elastic/blob/main/pics/pic1.png)

