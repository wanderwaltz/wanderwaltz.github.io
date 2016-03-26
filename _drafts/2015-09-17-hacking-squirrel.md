---
title: "Hacking Squirrel"
description: "Where I talk about making changes to the Squirrel itself"
date: 2015-09-17 21:51:00
tags: [Squirrel, C, C++]
---
Although the idea of making a [bindings library]({% post_url 2015-04-22-binding-swift-funcs %}) for
Squirrel in Swift kind of died off, I still like tinkering with the language and its inner workings.

Recently I've thought of making some fun stuff in Squirrel and got stuck because the VM does not
always work as I would expect. The good news is that since Squirrel is open source I can try to
modify it to meet my needs.
<!--more-->

## Delegates, thousands of them

Consider this excerpt from the Squirrel 3.0 [reference](http://squirrel-lang.org/doc/squirrel3.html#d0e2038):

>Squirrel supports implicit delegation. Every table or userdata can have a parent table (delegate).
A parent table is a normal table that allows the definition of special behaviors for his child. When
a table (or userdata) is indexed with a key that doesn’t correspond to one of its slots, the
interpreter automatically delegates the get (or set) operation to its parent.

It may be kind of cryptic for someone not familiar with Squirrel, but the concept is actually rather
simple:

{% highlight c %}
local delegate = {
    function getName() {
        return this.name;
    }
};

local table {
    name = "John Appleseed"
}

table.setdelegate(delegate);

print(table.getName()); // prints "John Appleseed"
{% endhighlight %}

Squirrel delegation is provided only for tables and userdata, as stated in the docs, but each
Squirrel type (including integers, floats, strings etc.[^1]) has a default delegate table, which contains
the standard functions to be used with these types (for example, integer default delegate has a
`tofloat` function, string default delegate has `len` etc.)

[^1]: Except the `null` type, which does not have a default delegate for no real reason. This is actually one of the things I've added in my fork of Squirrel: a default delegate for `null`.

## tostring() all the things!

All Squirrel data types have string representations. Squirrel also permits implicit string conversions
which allow doing things like

{% highlight c %}
print(object + "\n");
{% endhighlight %}

for `object` of any type. This gets really handy when debugging some code and printing the values
of local variables or function parameters. The only thing which is bugging me is that the container
types: tables and arrays have not that useful `(type: pointer)` string representations by default:

{% highlight c %}
local table = {
    name = "John Appleseed",
    age = 27
};

print(table+"\n");
{% endhighlight %}
>(table : 0x0x1002163e0)

I would prefer if the table's string representation included its elements, so this was the first thing
I've tried to add to Squirrel.

Each of the default delegates provides a `tostring` function, which returns a string representation
of the receiver. I thought this would be an ideal place for this customization. Just replace the
`tostring` function in table and array default delegates and call it a day, right?

Wrong.

It turns out, default Squirrel3 has a rather backwards logic regarding the string conversion.
Implicit string conversion mentioned above does not call the default delegate's `tostring` method
implementation at all, relying on the Squirrel VM's hardcoded `ToString` C++ method:

{% highlight cpp %}
bool SQVM::ToString(const SQObjectPtr &o,SQObjectPtr &res);
{% endhighlight %}

Default delegate's `tostring` is there only in case someone wants to call it explicitly and it
actually calls the same hardcoded `SQVM::ToString` internally. This implementation does not really
allow customization.

{% highlight cpp %}
bool SQVM::ToString(const SQObjectPtr &o,SQObjectPtr &res)
{
    switch(type(o)) {
    case OT_STRING:
        res = o;
        return true;
    case OT_FLOAT:
        scsprintf(_sp(rsl(NUMBER_MAX_CHAR+1)),_SC("%g"),_float(o));
        break;
    case OT_INTEGER:
        scsprintf(_sp(rsl(NUMBER_MAX_CHAR+1)),_PRINT_INT_FMT,_integer(o));
        break;
    case OT_BOOL:
        scsprintf(_sp(rsl(6)),_integer(o)?_SC("true"):_SC("false"));
        break;
    case OT_TABLE:
    case OT_USERDATA:
    case OT_INSTANCE:
        if(_delegable(o)->_delegate) {
            SQObjectPtr closure;
            if(_delegable(o)->GetMetaMethod(this, MT_TOSTRING, closure)) {
                Push(o);
                if(CallMetaMethod(closure,MT_TOSTRING,1,res)) {;
                    if(type(res) == OT_STRING)
                        return true;
                }
                else {
                    return false;
                }
            }
        }
    default:
        scsprintf(_sp(rsl(sizeof(void*)+20)),_SC("(%s : 0x%p)"),
            GetTypeName(o),(void*)_rawval(o));
    }
    res = SQString::Create(_ss(this),_spval);
    return true;
}
{% endhighlight %}


So in order to allow this kind of customization, this logic had to be [reversed](https://github.com/wanderwaltz/Squirrel/commit/d0036cc517b0b9146f579a2f687ec47ab387d0f2). I've added `SQVM::ToStringRaw`
method, which now contains the original string conversion logic, and `SQVM::ToString` now asks the
default delegate first and only then falls back to the 'raw' string conversion.

My latest implementation looks like this:
{% highlight cpp %}
bool SQVM::ToString(const SQObjectPtr &o,SQObjectPtr &res)
{
    return ToStringUsingDelegate(o, res) || // tables, userdata
           ToStringUsingDefaultDelegate(o, res) || // all types
           ToStringRaw(o, res);
}
{% endhighlight %}

And thus provides the customizability I'v sought. Table to string conversion is added as a natvie
function, which looks like this[^2]:

[^2]: Full source available in the [SqXtdLib](https://github.com/wanderwaltz/SqXtdLib) repo.

{% highlight cpp %}
SQRESULT tostring(HSQUIRRELVM vm) {
    sqxtd::string result("{\n");

    sq_pushnull(vm);

    while(SQ_SUCCEEDED(sq_next(vm, -2)))
    {
        static const SQInteger key_index = -2;
        static const SQInteger value_index = -1;

        auto key_value = sqxtd::format_key_value_at(vm,
            key_index, value_index);

        result += sqxtd::indent_string(key_value);
        result += "\n";

        sq_pop(vm,2);
    }

    result += "}";

    push_string(vm, result);
    return 1;
}
{% endhighlight %}

With these changes implemented, the above snippet yields much better result:

{% highlight c %}
local table = {
    name = "John Appleseed",
    age = 27
};

print(table+"\n");
{% endhighlight %}

><pre>{
    name = John Appleseed<br/>
    age = 27
}</pre>

I've made a similar change to the array default delegate, so it also lists all its elements when
converted to a string.
