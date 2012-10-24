-- | A demo to show that a tail-recursive function will not increase
-- the JavaScript stack.
--
-- See the ticket about optimizing tail-recursive functions for future
-- work <https://github.com/faylang/fay/issues/19>

{-# LANGUAGE NoImplicitPrelude #-}

module Tailrecursive where

import           Language.Fay.FFI
import           Language.Fay.Prelude

main = do
  benchmark $ printI (map (\x -> x+1) fibs !! 10)
  benchmark $ printI (fibs !! 80)
  benchmark $ printD (sum 1000000 0)
  benchmark $ printD (sum 1000000 0)
  benchmark $ printD (sum 1000000 0)
  benchmark $ printD (sum 1000000 0)

fibs = 0 : 1 : zipWith (+) fibs (tail fibs)

tail (_:xs) = xs

xs !! k = go 0 xs where
  go n (x:xs) | n == k = x
              | otherwise = go (n+1) xs

benchmark m = do
  start <- getSeconds
  m
  end <- getSeconds
  printS (show (end-start) ++ "ms")

length' :: [a] -> Int
length' = go 0 where
  go acc (_:xs) = go (acc+1) xs
  go acc [] = acc

-- tail recursive
sum 0 acc = acc
sum n acc = sum (n - 1) (acc + n)

getSeconds :: Fay Double
getSeconds = ffi "new Date()"

printD :: Double -> Fay ()
printD = ffi "console.log(%1)"

printI :: Int -> Fay ()
printI = ffi "console.log(%1)"

printS :: String -> Fay ()
printS = ffi "console.log(%1)"
