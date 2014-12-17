{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Applicative
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import           Network.WebSockets
import           Network.WebSockets.Snap
import           System.FSNotify
import           Control.Concurrent.Chan
import           Control.Concurrent(forkIO)
import           Control.Monad(void,forever)
import           Data.Text.Lazy(pack)
import           Filesystem.Path.CurrentOS(encodeString)
import           System.Directory

main :: IO ()
main = withManager $ \mgr -> do
    chan <- newChan
    _ <- watchTreeChan mgr "." (const True) chan
    printChanges chan
    quickHttpServe $
        path "//__index.html" (serveFile "frame.html") <|>
        path "__ws" (runWebSocketsSnap $ ws chan) <|>
        serveDirectory "."

ws :: EventChannel -> ServerApp
ws chan' pending = do
    chan <- dupChan chan'
    conn <- acceptRequest pending
    sendTextData conn $ pack "index.html"
    forever $ do
        res <- readChan chan
        res_path <- makeRelativeToCurrentDirectory $ encodeString $ eventPath res
        sendTextData conn $ pack res_path

printChanges :: EventChannel -> IO ()
printChanges chan = void $ forkIO $ forever $ do
    res <- readChan chan
    print res
