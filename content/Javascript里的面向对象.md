Title: OOP in Javascript
Author: 齐德隆冬
Date: 2017-12-03
Modified: 2017-12-26
Category: 技术研究[node]
Tags: nodejs,面向对象
Summary: 在JS里如何按面向对象的写法来写呢


*注：这篇文章是分享给公司的同事的，考虑到一直使用nodejs可能会缺乏一些面向对象概念基础，因此在这篇文章里讲了下。*


### 首先是几个术语

| Name      | description                    |
| --------- | ------------------------------ |
| Object    | 对象，用于描述一类，一种或者一个具体事物，该事物有属性与方法 |
| Function  | 方法，通常可以执行                      |
| Attribute | 属性，属性会有各种类型，也可以是对象             |
| Class     | 类，表述一类事物，可以是抽象的                |
| Instance  | 实例，指一个具体的事物                    |



### Javascript OOP way (with ES6 syntax support)

```js

class User {
    constructor (name, email) {
        this.name = name;  // 实例属性
        this.email = email;
        // 类的构造方法，初始化的时候会调用，默认return this;当然也可以返回其它的
    }

    getName () { // 实例方法，等同于下面的prototype的写法
        return this.name; // this是这个类的实例
    }

    static getUser() { // 写法同等于在外面写类方法

    }
    
}

User.prototype.getEmail = function () { // 这种写法与上面的写法一样，其实这个是ES6->ES5的原理
    return this.email;
}

User._cachedUser = {} // 类属性，表示这一类事物共有的属性

User.getUser = function (name) { // 类方法
    if (name in this._cachedUser) {
        return this._cachedUser[name];
    } else {
        var tempUser = new User(name, "");
        this._cachedUser[name] = tempUser;
        return tempUser;
    }
}

```


上面的例子，应该会比较清晰的看到有几种不同的概念：

* 类属性
* 类方法
* 实例属性
* 实例方法

上面的例子中，类共用了一个`_cachedUser`，用作存储User实例的字典。
然后类提供了`getUser`的方法，从上面的属性中取到用户，以达到不用每次都从数据库中取用户的目的。
这里体现的是`享元模式`，一种类似于`单例模式`的设计模式。
实例的属性和方法这个应该很好理解。

但是原来JS里是并没有class关键字的，以上是如何实现的呢？


```js

function User(name, email) {
    this.name = name;
    this.email = email;

    this.getName = function () {
        return this.name;
    }
}

let name = "anyone";
let email = "fake@no.com"

var empty = User(name, email);  // undefined
var user = new User(name, email); // User {name: "anyone", email: "fake@no.com"}

```

为什么有不同的区别呢？
关键就是在于`new`，`new`其实就是执行了`User`方法，并且返回了这个方法this本身；
除此之外，上面的`getName`跟上面class的写法其实又不一样。
这里每个`getName`方法都是重新声明的，JS里为了节约这个开销，引入了`prototype`的概念，`prototype`的数据挂在方法下面，通过new出来的实例，会通过prototype拿到实例的属性或者方法。


### 来点实例吧

上面讲了JS的OOP的写法，并简单介绍了一下基本原理。还是讲点例子来演示如何以OO的写法来改善代码吧。

在此之前，我们先来讲讲ORM吧。

要讲清楚ORM之前，我们还是先讲一下没有ORM的使用下，我们如何使用数据库。

1. 建立数据库连接
2. 拼装准备SQL
3. 执行SQL
4. 返回数据

ORM的实现原理略微有点复杂，这里略过不讲，nodejs里有现成的`sqeuelize`可以使用。

即定义好模型与数据库中的表一一映射起来，以下是一些伪代码。

```js

class Order {

    constructor(id, productId, status) {
        this.id = id;
        this.productId = productId;
        this.stauts = status;
    }

}

Order.findAll = function (query) {
    return sequelize.executeSql("select id, item from core_order").then(queryResult=>{
        let objList = [];
        for (var row of queryResult) {
            objList.push(new Order(row));
        }
    });
}

Order.findOne = function (query) {
    // 将查询字段映射成SQL
    return sequelize.executeSql("select id, item from core_order limit 1").then(queryResult=>{
        return queryResult.length >0 ? new Order(queryResult[0]) : null;
    });;
}

```

`findAll`与`findOne`均是绑定到Order上的类方法，会返回`Order`的实例列表或单个实例。


以核心的订单、保单对外的查询、详情为例：

如果以restful风格来提供API，那么，url映射与功能大概如下：

| url          | method | 说明     |
| ------------ | ------ | ------ |
| `orders/`    | GET    | 查询订单   |
| `orders/:id` | GET    | 获取订单详情 |

那么后台的功能其实也就非常简单：

```js

router.get("orders/", function(req, res) {
    Order.findAll().then(orderList=>{
        res.json({orderList});
    });
});


router.get("orders/:id", function(req, res) {
    Order.findOne({where: {id: req.params.id}}).then(order=>{
        if (order) {
            res.json({order});
        } else {
            res.status(404).json({});
        }
    });
});


```

可以看到，上面用这些代码，实际开发的量较少，就可以达到较实用的功能了。
然后我们还可以进一步增加保单的接口：


```js

router.get("policy/", function(req, res) {
    Policy.findAll().then(policyList=>{
        res.json({policyList});
    });
});


router.get("policys/:id", function(req, res) {
    Policy.findOne({where: {id: req.params.id}}).then(policy=>{
        if (policy) {
            res.json({policy});
        } else {
            res.status(404).json({});
        }
    });
});

```

可以看到，其实上面的代码非常接近，在这个基础上，当然可以造一个基础类：

```js


class BaseRESTViewSet {

    constructor(model) {
        this.model = model;
    }

    getList(req, res) {
        this.model.findAll().then(objList=>{
            res.json({objList});
        });
    }

    getOne(req, res) {
        this.model.findOne({where: {id: req.params.id}}).then(obj=>{
            if (obj) {
                res.json({obj})
            } else{
                res.status(404).json({});
            };
        });
    }
}

var orderViewSet = new BaseRESTViewSet(Order);
var policyViewSet = new BaseRESTViewSet(Policy);

// 需要bind，否则express里的middware异步调用的时候，会丢失掉该就方法的this对象
router.get("orders/", orderViewSet.getList.bind(orderViewSet)); 
router.get("orders/:id", orderViewSet.getOne.bind(OrderViewSet));
router.get("policys/", policyViewSet.getList.bind(policyViewSet));
router.get("policys/:id", policyViewSet.getOne.bind(policyViewSet));


```

当然，上面的代码也只是因为业务简单，实际中会遇到不同的表的查询条件不一样或者需要关联查询等，逻辑就会更复杂。


其它应用：

* 自定义异常，用于返回不同的消息提示


### 深入的话题？

* 异步回调时的对象绑定(使用bind可以提前将对象绑定到方法上去)
* 元类(metaclass类似的机制，即动态生成一个类对象，JS里的constructor可以修改后return，也可以使用proxy)
* 装饰器(decorators)
* mixins(multi inherit，其实跟单继承原理一样，多继承时会有继承顺序的问题)
* Design Patterns
