## The smallest free number

[소스 코드](minFree.hs)

주어진 유한 개의 자연수 집합 X에 포함되지 않는 가장 작은 자연수를 찾는 문제.

예를 들어 숫자 집합이 [10,15,6,4,1,9,2,3,5,7,0]이면 답은 8이 되어야 한다.

O(n)의 시간 복잡도로 풀 수 있고, 두 가지 방향의 해법이 있다.

### Solution 1. 배열(Array) 기반

이 문제의 답을 구하는 함수 이름을 `minFree`라고 하자.

```Haskell
minFree :: [Int] -> [Int]
minFree xs = head ([0..] \\ xs)
```
 
간단하게 생각하면 위와 같은 방식으로도 풀 수 있다. 하지만 이 경우 시간 복잡도는 O(n^2).

이 문제를 풀기 위한 핵심 아이디어는 [0..length xs] 범위 안에 있는 숫자들이 모두 xs 안에 존재하지는 않는다는 것이다. 이는 [0..length xs] 집합이 그냥 xs 집합보다 크기가 하나 더 크기 때문에 당연하다.

그러면 xs에 포함되지 않는 가장 작은 원소는 `filter (<= length xs) xs`에 포함되지 않는 가장 작은 원소와 동일하게 된다.

이제 `filter (<= n) xs`의 원소에 대한 체크리스트를 만들면 문제를 쉽게 풀 수 있다. 즉, `0~n` 까지의 인덱스에 대해서 그 인덱스 값이 `filter (<=n) xs`안에 속하는 값이면 `True`, 아니면 `False`인 체크리스트를 만들고 처음으로 값이 `False`인 인덱스를 찾으면 되는 것이다.

이는 아래와 같은 함수로 구현할 수 있다.

```Haskell
minFree :: [Int] -> Int
minFree = search . checklist

search :: Array Int Bool -> Int
search = length . takeWhile id . elems

checklist :: [Int] -> Array Int Bool
checklist xs = accumArray (||) False (0,n) (zip (filter (<=n) xs) (repeat True))
    where n = length xs
```

`search`는 만들어진 체크 리스트에서 첫 번째 `False`의 위치를 찾는 함수, `checklist`는 주어진 리스트에서 체크리스트를 만드는 함수로 생각하면 된다. `accumArray` 등의 함수가 무슨 의미인지만 알면 어렵지 않은 코드니 설명은 생략.

### Solution 2. 분할 정복 기반

분할 정복을 쓰려면 주어진 문제를 적절히 유사한 형태의 부분 문제로 변환할 수 있어야 한다.

이 해법에서는 아래의 특성이 핵심적으로 사용된다.

어떤 리스트 as, bs, us, vs가 있다. 이 때 as와 vs가 서로소이고 bs와 us가 서로소면 아래의 등식이 성립한다.

`(as ++ bs) \\ (us ++ vs) = (as \\ us) ++ (bs \\ vs)`

이제 임의의 자연수 b에 대해서, `as = [0..b-1]`, `bs=[b..]`라고 하자. 또, `us = filter (<b) xs`, `vs = filter (>=b) xs`로 정의하자.
그러면 당연히 as와 vs는 서로소가 되고, bs와 us도 서로소가 된다. 이로부터 아래의 식이 성립함을 알 수 있다.

```Haskell
[0..] \\ xs = ([0..b-1] \\ us) ++ ([b..] \\ vs)
    where (us, vs) = partition (<b) xs
```

`partition`은 리스트를 특정 조건 `p`를 만족하는 리스트와 만족하지 못하는 리스트 두 개로 나누는 함수다. 이 성질을 이용하면 `minFree`를 다음과 같이 정의할 수 있다.

```Haskell
minFree xs = if null ([0..b-1] \\ us)
             then head ([b..] \\ vs)
             else head ([0..] \\ us)
             where (us, vs) = partition (<b) xs
```

하지만 여기서 문제는 `a \\ b` 연산이 O(length a * length b)만큼의 시간을 요구한다는 것이다. 이는 우리가 원하던 O(n) 해법이 아니다.

이 문제를 해결하기 위해서 다음의 성질을 사용할 수 있다.

```Haskell
null ([0..b-1] \\ us) = length us == b
```

리스트의 모든 원소가 서로 다른 값이라면(문제에서는 자연수 '집합'이기 때문에 당연히 모든 원소는 서로 다른 값이다. 다만, 위의 solution 1의 경우는 원소들 중 중복되는 값이 있더라도 사용 가능하다.) 당연히 성립하는 성질이다.

왜냐하면, us는 리스트 xs에서 b보다 작은 값들만 걸러낸 리스트이고, 또 리스트의 모든 원소는 서로 다른 값이기 때문이다. 그렇다면 us의 길이가 b일 경우 us 리스트는 반드시 [0..b-1]이 될 수 밖에 없다.

이제 이 성질로부터 minFree의 정의를 살짝 비틀어보자.

```Haskell
minFree xs = minFrom 0 xs
minFrom a xs
    | null xs = a
    | length us == b - a = minFrom b vs
    | otherwise = minFrom a us
    where (us, vs) = partition (<b) xs
```

이제 임의의 자연수 b를 어떻게 정할 것이냐에 관한 문제만 남았다. 수행시간을 최대한 줄이려면 us와 vs가 적절히 절반이 되게 나누어줘야 할 것이다.

이는 간단하게, ```b = a + 1 + n `div` 2```로 구할 수 있다. 이 때 n은 `length xs`.

이렇게 b를 정의하면 `us`의 길이와 `vs`의 길이는 ```n `div` 2```를 넘지 못한다. 즉, 한 번 호출될 때마다 문제 사이즈가 반으로 줄어드는 것이다.

여기서 시간복잡도를 생각해보면 `T(n) = T(n div 2) + O(n)`이고 따라서 `T(n) = O(n)`이다.

다만 Haskell에서 리스트의 길이를 구하는 연산은 `O(n)`만큼의 비용이 소모되기 때문에, 이 부분을 해결하기 위한 최적화가 필요하다.

```Haskell
minFree xs = minFrom 0 (length xs, xs)
minFrom a (n, xs)
    | n == 0 = a
    | m == b - a = minFrom b (n - m, vs)
    | otherwise = minFrom a (m, us)
    where (us, vs) = partition (<b) xs
          b = a + 1 + n `div` 2
          m = length us
```

이 방법이 실제로 실행해보면 `solution 1`보다 20% 정도 빠르다고 한다.