Title:实现python中的枚举类型 ——python的metaclass应用举例
Author: 齐德隆冬
Date: 2015-10-24
Modified: 2015-10-24 16:24
Category: 技术研究[python]
Tags: python, enum, metaclass
Summary: python的枚举类型实现，使用metaclass动态构建类属性


##### 什么是枚举类型？

对于较熟悉c或java的程序员来说，这个可能再简单不过。如：

```c
enum DAY
{
     MON=1, TUE, WED, THU, FRI, SAT, SUN
};
```

以DAY.MON来表示周一，能避免使用魔鬼数字，提高代码可读性。

##### python中？

python 3.4中是直接有Enum类型的，可以较方便的创建枚举类型：

```python
from enum import Enum
Animal = Enum('Animal', 'ant bee cat dog')
```

其实也有较简单的办法自己写：

```python
class Animal(object):
     ant = 1
     bee = 2
     cat = 3
     dog = 4

```

##### 问题解决了？

No，当然没有完全解决。

这里以django框架中的models为例，以下是一个常见的模型定义

```python
class Person(models.Model):

     name = CharField(verbose_name = "姓名")
     gender = IntegerField(verbose_name = "性别", choices = ((0, '女'), (1, '男')))

```

这里也必须要提到另一点了：`metaclass`，上例中，Person实例化的类，是带有这样的一个方法的：`get_gender_display()`

```python
zax = Person(name = "Zax", gender = 1)
print zax.get_gender_display()

>>> 男

```

这里解决了一部分问题，仍然遗留了这些问题：

1. 数据库查询时，必须要使用魔鬼数字，比如`Person.objects.filter(gender = 1)` 用于查询男性
2. 关联统计时，比如有其它关联Person的表，需要分类统计性别差异，返回的数据，仍然是1或0，而不是可读性更高的“男”或“女”。

二者结合一下：

```python
class GenderEnum(object):

     male = 1
     female = 0

     choices = ((male,  '男'), (female, '女'))

     @classmethod
     def get_gender_display(cls, enum_type):
          return dict(cls.choices).get(enum_type, enum_type)

class Person(models.Model):

     gender = IntegerField(verbose_name = "性别", choices =  GenderEnum.choices)

# 查询
Person.objects.filter(gender = GenderEnum.male)

```

问题解决。but...

身为一个爱折腾的程序员，当然是不想每次都写这个choices的。

其实每个枚举类型，除了有值以外，还有描述，即：

```python
class EnumType(object):
     def __int__(self, value, desc):
          self.value = value
          self.desc = desc

class GenderEnum(object):
     male = EnumType(1, '男')
     female = EnumType(0, '女')

```

这样的话，choices，display均可以用父类构造，不用自己再手动写了。but...

GenderEnum.male返回的却是EnumType的实例，换成GenderEnum.male.value，总感觉不舒服斯基。。。

这里就可以学着metaclass来动态构造类的属性，把GenderEnum.male由原来的EnumType改成male的数值1。

即，在创建GenderEnum这个类的时候，截取它的属性，并将EnumType的字段，修改为其值。

简言之，`在创建类时，替换类的属性。`效果等同于以下代码所示

```python
GenderEnum.male = GenderEnum.male.value

```

以下就是代码：

```python
# coding=utf-8

class EnumType(object):
    def __init__(self, value, desc):
        self.value = value
        self.desc = desc

class MetaEnum(type):
    def __new__(cls, name, bases, attrs):
        if name != 'MetaEnum':
            enum_choices = []
            enum_desc_dict = {}
            enum_value_dict = {}
            for k, v in attrs.items():
                if isinstance(v, EnumType):
                    enum_choices.append((v.value, v.desc))
                    enum_desc_dict.update({v.value: v.desc})
                    enum_value_dict.update({k: v.value})
            attrs.update({
                'ENUM_CHOICES': tuple(enum_choices),
                'ENUM_DESC_DICT': enum_desc_dict
            })
            attrs.update(enum_value_dict)
        new_cls = super(MetaEnum, cls).__new__(cls,name,bases,attrs)
        return new_cls

class BaseEnum(object):
    __metaclass__ = MetaEnum

    ENUM_CHOICES = () # 字段choices
    ENUM_DESC_DICT = {} # 描述字段

    @classmethod
    def display(cls, value):
        return cls.ENUM_DESC_DICT.get(value, value)

class GenderEnum(BaseEnum):
     male   = EnumType(1, u'男')
     female = EnumType(0, u'女')
     unknow = EnumType(2, u'未知')

if __name__ == "__main__":
    print GenderEnum.male
    print GenderEnum.ENUM_CHOICES
    print GenderEnum.display(2)

```