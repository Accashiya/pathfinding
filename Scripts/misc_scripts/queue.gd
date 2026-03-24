class_name Queue

var data:Array = []
var head:int = 0

func enqueue(value):
    data.append(value)

func dequeue():
    if head >= data.size():
        return null
    
    var value = data[head]
    head += 1
    return value

func is_empty():
    return head >= data.size()

func size():
    return data.size() - head