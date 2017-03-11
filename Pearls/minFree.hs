-- solution of the smallest free number

-- solution 1

import Data.Array
import Data.List

minFree :: [Int] -> Int
minFree = search . checklist

search :: Array Int Bool -> Int
search = length . takeWhile id . elems

checklist :: [Int] -> Array Int Bool
checklist xs = accumArray (||) False (0,n) (zip (filter (<=n) xs) (repeat True))
    where n = length xs

-- solution 2

minFree' :: [Int] -> Int
minFree' xs = minFrom 0 (length xs, xs)

minFrom :: Int -> (Int, [Int]) -> Int
minFrom a (n, xs)
    | n == 0 = a
    | m == b - a = minFrom b (n - m, vs)
    | otherwise = minFrom a (m, us)
    where (us, vs) = partition (<b) xs
          b = a + 1 + n `div` 2
          m = length us