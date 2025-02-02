module Main where

import System.Environment (getArgs)
import Host (init_host)
import Publish (init_subscriber)

main :: IO ()
main = do
    args <- getArgs
    case args of
        ["host"] -> init_host
        ["subscribe", host] -> do
            putStrLn $ "Subscribing to host at: " ++ host
            putStrLn "Subscription logic is not implemented yet."
        ["publish", host] -> do
            putStrLn $ "Starting subscriber and publishing to host: " ++ host
            init_subscriber
        _ -> putStrLn "Usage: daywma (host | subscribe <host> | publish <host>)"
