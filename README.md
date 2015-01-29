# khipu

[![Build Status](https://travis-ci.org/khipu/lib-ruby.png)](https://travis-ci.org/khipu/lib-ruby)

[khipu - Yo pago, Yo cobro](https://khipu.com)

Gema Ruby para utilizar los servicios de Khipu.com

Versión API Khipu: 1.3
Versión API de notificación: 1.2

La documentación de Khipu.com se puede ver desde aquí: [https://khipu.com/page/api](https://khipu.com/page/api)

## Uso

Primero instalar la gema ruby

```Bash
    $ gem install khipu
```

Luego debes incluir la gema desde tus scripts Ruby usando _require 'khipu'_

## Operaciones

Esta biblioteca implementa los siguientes servicios de khipu:

1. Obtener listado de bancos
2. Crear cobros y enviarlos por mail. 
3. Crear una página de Pago.
4. Crear una página de Pago (autenticado).
5. Crear un pago y obtener us URL.
6. Crear un pago y obtener us URL (autenticado).
7.1. Recibir y validar la notificación de un pago (API de notificación 1.3 o superior).
7.2. Recibir y validar la notificación de un pago (API de notificación 1.2 o inferior).
8. Verificar el estado de una cuenta de cobro.
9. Verificar el estado de un pago.
10. Marcar un pago como pagado.
11. Marcar un cobro como expirado.
12. Marcar un pago como rechazado.


### 1) Obtener listado de bancos.

Este servicio entrega un mapa con el listado de los bancos disponibles para efectuar un pago a un cobrador determinado.
Cada banco tiene su identificador, un nombre, el monto mínimo que se puede transferir desde él y un mensaje con
información importante.

```Ruby
    begin 
        banks = Khipu.create_khipu_api(ID_DEL_COBRADOR, 'SECRET_DEL_COBRADOR').receiver_banks
    rescue Khipu::ApiError  => error
        puts error.type
        puts error.message
    end
```

### 2) Crear cobros y enviarlos por mail.

Este servicio entrega un mapa que contiene el identificador del cobro generado así como una lista de los pagos asociados
a este cobro. Por cada pago se tiene el ID, el correo asociado y la URL en khipu para pagar.

```Ruby
    begin 
        service = Khipu.create_khipu_api(ID_DEL_COBRADOR, SECRET_DEL_COBRADOR)
        map = service.create_email({subject: 'Un cobro desde Ruby', destinataries: [ {name: "John Doe", email: "john.doe@gmail.com", amount: "1000"}, {name: "Jane Dow", email: "jane.dow@gmail.com", amount: "1000"}], pay_directly: true, send_emails: true})
    rescue Khipu::ApiError => error
        puts error.type
        puts error.message
    end
```
*Importante*: El parámetro _destinataries_ es un mapa Ruby y no un string. Internamente es convertido a un string JSON

### 3) Crear una página de Pago.

Este ejemplo genera un archivo .html con un formulario de pago en khipu.

```Ruby
    File.open('form.html', 'w') { |file|
        service = Khipu.create_html_helper(2, 'e40ac9591200b2ec9277cd1c795af82d618cf78e')
        form = service.create_payment_form({subject: 'Un cobro desde Ruby', body: 'El cuerpo del cobro', amount: "1000", email: 'john.doe@gmail.com'})
        file.write(form)
    }
```

### 4) Crear una página de Pago (autenticado).

Para crear una página de pago que solo permita pagar usando una cuenta asociada a un RUT en particular debes usar el
mismo servicio del punto anterior indicando el RUT en el parámetro _payer_username_

```Ruby
    File.open('form.html', 'w') { |file|
        service = Khipu.create_html_helper(2, 'e40ac9591200b2ec9277cd1c795af82d618cf78e')
        form = service.create_payment_form({subject: 'Un cobro desde Ruby', body: 'El cuerpo del cobro', amount: "1000", email: 'john.doe@gmail.com', payer_username: '128723463'})
        file.write(form)
    }
```

### 5) Crear un pago y obtener su URL.

Este servicio entrega un mapa que contiene el identificador de un pago generado, su URL en khipu y la URL para iniciar
el pago desde un dispositivo móvil.

```Ruby
    begin 
        service = Khipu.create_khipu_api(ID_DEL_COBRADOR, SECRET_DEL_COBRADOR)
        map = service.create_payment_url({subject: 'Un cobro desde Ruby', body: 'El cuerpo del cobro', amount: "1000", email: 'john.doe@gmail.com'})
    rescue Khipu::ApiError => error
        puts error.type
        puts error.message
    end
```
### 6) Crear un pago y obtener su URL (autenticado).

Este servicio es idéntico al anterior pero usando el parámetro _payer_username_ se fuerza que la cuenta corriente usada
para pagar debe estar asociada al RUT indicado.

```Ruby
    begin
        service = Khipu.create_khipu_api(ID_DEL_COBRADOR, SECRET_DEL_COBRADOR)
        map = service.create_authenticated_payment_url({subject: 'Un cobro desde Ruby', body: 'El cuerpo del cobro', amount: "1000", email: 'john.doe@gmail.com', payer_username: '128723463'})
    rescue Khipu::ApiError => error
        puts error.type
        puts error.message
    end
```

### 7.1) Validar la notificación de un pago (API de notificación 1.3 o superior)

Este ejemplo contacta a khipu para obtener la notificación de un pago a partir de un token de notificación.
El resultado contiene el receiver_id, transaction_id, amount, currency, etc con lo que se debe el pago contra el backend.
En este ejemplo los parámetros se configuran a mano, pero en producción los datos deben obtenerse desde el request _request html_.

```Ruby
    begin
        service = Khipu.create_khipu_api(ID_DEL_COBRADOR, SECRET_DEL_COBRADOR)
        params = {notification_token: 'j8kPBHaPNy3PkCh...hhLvQbenpGjA'}
        map = service.get_payment_notification(params)
    rescue Khipu::ApiError => error
        puts error.type
        puts error.message
    end
``````

En map queda un hash con los valores de la notificación:

```Ruby
    {
        "notification_token"=>"j8kPBHaPNy3PkCh...hhLvQbenpGjA",
        "receiver_id"=>ID_DEL_COBRADOR,
        "subject"=>"Motivo del cobro",
        "amount"=>"100",
        "custom"=>"",
        "transaction_id"=>"MTX_123123",
        "payment_id"=>"qpclzun1nlej",
        "currency"=>"CLP",
        "payer_email"=>"ejemplo@gmail.com"
    }
``````

### 7.2) Validar la notificación de un pago (API de notificación 1.2 o inferior).

Este ejemplo contacta a khipu para validar los datos de una transacción. Para usar
este servicio no es necesario configurar el SECRET del cobrador. Se retorna true si la información del la notificación
es válida. En este ejemplo los parámetros se configuran a mano, pero en producción los datos deben obtenerse desde
el _request html_.

```Ruby
    begin 
        service = Khipu.create_khipu_api(ID_DEL_COBRADOR, SECRET_DEL_COBRADOR)
        params = {api_version: '1.2', 
                notification_id: 'aq1td2jl2uen', 
                subject: 'Motivo de prueba', 
                amount: 12575,
                currency: 'CLP', 
                transaction_id: 'FTEEE5SWWO', 
                payer_email: 'john.doe@gmail.com',
                custom: 'Custom info', 
                notification_signature: 'j8kPBHaPNy3PkCh...hhLvQbenpGjA=='
        }
        valid = service.verify_payment_notification(params)
    rescue Khipu::ApiError => error
        puts error.type
        puts error.message
    end
```


### 8) Verificar el estado de una cuenta de cobro.

Este servicio permite consultar el estado de una cuenta khipu. Se devuelve un mapa que indica si esta cuenta está
habilitada para cobrar y el tipo de cuenta (desarrollo o producción).

```Ruby
    begin 
        service = Khipu.create_khipu_api(ID_DEL_COBRADOR, SECRET_DEL_COBRADOR)
        map = service.receiver_status; 
    rescue Khipu::ApiError => error
        puts error.type
        puts error.message
    end
```
 
### 9) Verificar el estado de un pago.

Este servició sirve para verificar el estado de un pago.

```Ruby
    begin 
        service = Khipu.create_khipu_api(ID_DEL_COBRADOR, SECRET_DEL_COBRADOR)
        map = service.payment_status({payment_id: '9fnsggqqi8ho'})
    rescue Khipu::ApiError  => error
        puts error.type
        puts error.message
    end
```

### 10) Marcar un cobro como pagado.

Este servicio permite marcar un cobro como pagado. Si el pagador paga por un método alternativo a khipu, el cobrador
puede marcar este cobro como saldado.

```Ruby
    begin 
        service = Khipu.create_khipu_api(ID_DEL_COBRADOR, SECRET_DEL_COBRADOR)
        service.set_paid_by_receiver({payment_id: '54dhfsch6avd'});
    rescue Khipu::ApiError => error
        puts error.type
        puts error.message
    end
```

### 11) Marcar un cobro como expirado.

Este servicio permite adelantar la expiración del cobro. Se puede adjuntar un texto que será desplegado a la gente que
trate de ir a pagar.


```Ruby
    begin 
        service = Khipu.create_khipu_api(ID_DEL_COBRADOR, SECRET_DEL_COBRADOR)
        service.set_bill_expired({bill_id: 'udmEe', text: 'Plazo vencido'})
    rescue Khipu::ApiError => error
        puts error.type
        puts error.message
    end
```

### 12) Marcar un cobro como rechazado.

Este servicio permite rechazar pago con el fin de inhabilitarlo. Permite indicar la razón por la que el pagador rechaza
saldar este pago:


```Ruby
    begin 
        service = Khipu.create_khipu_api(ID_DEL_COBRADOR, SECRET_DEL_COBRADOR)
        service.set_rejected_by_payer({payment_id: '0pk7xfgocry4', text: 'El pago no corresponde'});
    rescue Khipu::ApiError => error
        puts error.type
        puts error.message
    end
```
