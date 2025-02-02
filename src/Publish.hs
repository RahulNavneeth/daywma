{-# LANGUAGE OverloadedStrings #-}

module Publish where

import System.Process
import Network.HTTP.Simple
import Control.Concurrent.Async
import qualified Data.ByteString as B
import qualified Data.ByteString.Base64 as B64
import Web.Scotty
import System.Info (os)

take_screenshot :: IO B.ByteString
take_screenshot = do
    let file_name = "screenshot.png"
    if os == "linux" || os == "darwin" then
        _ <- callCommand "scrot screenshot.png"
    else if os == "mingw32" then
        _ <- callCommand "python -m mss.cli screenshot.png"
    else
        error "Unsupported OS"
    B.readFile file_name

publish_screenshot :: String -> IO ()
publish_screenshot host = do
    img <- take_screenshot
    let encoded_img = B64.encode img
    let req = setRequestBodyJSON (object ["image" .= encoded_img])
                $ parseRequest_ (host ++ "/publish")
    _ <- httpNoBody req
    putStrLn "Screenshot sent!"

init_subscriber :: IO ()
init_subscriber = scotty 5000 $ do
    post "/capture" $ do
        liftIO $ do
            putStrLn "Capturing screenshot..."
            img <- take_screenshot
            let encoded_img = B64.encode img
            let req = setRequestBodyJSON (object ["image" .= encoded_img])
                        $ parseRequest_ "http://localhost:4000/publish"
            _ <- httpNoBody req
            putStrLn "Screenshot sent to the host!"
        json $ object ["message" .= ("Screenshot captured and sent" :: String)]
