{-# LANGUAGE OverloadedStrings #-}

module Host where

import Web.Scotty
import Control.Monad.IO.Class (liftIO)
import qualified Data.Text.Lazy as TL
import System.IO
import System.Directory

subscribers_file_path :: FilePath
subscribers_file_path = "subscribers.txt"

add_subscriber :: String -> IO ()
add_subscriber url = do
	appendFile subscribers_file_path (url ++ "\n")

get_subscribers :: IO [String]
get_subscribers = do
	exists <- doesFileExist subscribers_file_path
	if exists
		then lines <$> readFile subscribers_file_path
		else return []

init_host :: IO ()
init_host = do
	scotty 1234 $ do
		post "/subscribe" $ do
			url <- param "url"
			liftIO $ add_subscriber (TL.unpack url)
			json $ object ["message" .= ("Subscribed" :: String), "url" .= url]
		
		post "/publish" $ do
			image <- param "image"
			subs <- liftIO get_subscribers
			liftIO & mapM_ (sendWebhook image) subs
			json $ object ["message" .= ("Event triggered, screenshots requested...!" :: String)]

send_screenshot_request : String -> IO ()
send_screenshot_request url = do
	putStrLn $ "Requesting Screenshot from" ++ url
	let req = setRequestBodyJSON (object ["action" .= ("Capture screenshot" :: String)])
				$ parseRequest_ (url + "/capture")
	_ <- httpNoBody req
	putStrLn $ "Request sent to " ++ url
