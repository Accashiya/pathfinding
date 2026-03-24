class_name MinHeap

# Values need to store a heapIndex int
# also a <left>.CompareTo(<right>) function which return -1 if left < right, 0 if left == right, 1 if left > right

var heap: Array = []

func ParentIndex(i:int) -> int:
	return (i-1)/2

func LeftChildIndex(i:int) -> int:
	return (2*i) + 1

func RightChildIndex(i:int) -> int:
	return (2*i) + 2

func Swap(value_1, value_2) -> void:
	var temp = value_1
	heap[value_1.heapIndex] = value_2
	heap[value_2.heapIndex] = temp

	var tempI = temp.heapIndex
	value_1.heapIndex = value_2.heapIndex
	value_2.heapIndex = tempI

func Add(value):
	heap.append(value)
	value.heapIndex = heap.size()-1
	SortUp(heap.size()-1)

func Pop():
	if heap.is_empty():
		return null
	
	var root = heap[0]
	root.heapIndex = -1

	var lastValue = heap.pop_back()

	if !heap.is_empty():
		heap[0] = lastValue
		lastValue.heapIndex = 0
		SortDown(0)

	return root

func SortUp(i: int) -> void:
	while (i > 0 && heap[i].CompareTo(heap[ParentIndex(i)]) < 0):
		Swap(heap[i], heap[ParentIndex(i)])
		i = ParentIndex(i)

func SortDown(i: int) -> void:
	var currentIndex = i
	var leftIndex = LeftChildIndex(i)
	var rightIndex = RightChildIndex(i)

	if leftIndex < heap.size() and heap[leftIndex].CompareTo(heap[currentIndex]) < 0:
		currentIndex = leftIndex

	if rightIndex < heap.size() and heap[rightIndex].CompareTo(heap[currentIndex]) < 0:
		currentIndex = rightIndex

	if currentIndex != i:
		Swap(heap[currentIndex], heap[i])
		SortDown(currentIndex)

func Peek():
	return heap[0]

func Size() -> int:
	return heap.size()

func IsEmpty() -> bool:
	return heap.is_empty()

func Contains(value) -> bool:
	var i = value.heapIndex
	if i < 0 or i >= heap.size():
		return false

	return heap[i] == value

func UpdateItem(item):
	SortUp(item.heapIndex)
