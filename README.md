# Домашняя работа "Централизованный сбор логов в кластер Elasticsearch"

Цель работы - настроить сбор логов веб-проекта в кластер ELK.

В качестве веб-проекта взята домашняя работа "Настройка конфигурации веб приложения под высокую нагрузку" (https://github.com/Esperakus/homework_web-hl). К существующим ролям той работы добавлена роль filebeat (назначается на все ВМ в проекте), кластер Elasticsearch из трёх нод, ВМ с logstash и Kibana. Для удобства Kibana имеет доступ из интернета.


Схема проекта:
![alt text](https://github.com/Esperakus/homework_elastic/blob/main/pics/pic3.png)

Для разворачивания проекта необходимо:

1. Заполнить значение переменных cloud_id, folder_id и iam-token в файле **variables.tf**.

2. Инициализировать рабочую среду Terraform:

```
$ terraform init
```
В результате будет установлен провайдер для подключения к облаку Яндекс.

3. Запустить разворачивание:
```
$ terraform apply
```
По окончании разворачивания в выходных данных будут показаны все внешние и внутренни ip адреса. 

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

Для просмотра логов надо зайти в Кибану по адресам http://{external_ip_address_kibana}:5601/app/observability/overview и http://{external_ip_address_kibana}:5601/app/logs/stream, там можно увидеть статистику сбора логов и сами логи. Также можно настроить фильтры и произвести поиск.

Примеры того как выглядят собранные логи в кибане:
![alt text](https://github.com/Esperakus/homework_elastic/blob/main/pics/pic2.png)
![alt text](https://github.com/Esperakus/homework_elastic/blob/main/pics/pic1.png)
