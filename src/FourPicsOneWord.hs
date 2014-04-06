{-# LANGUAGE OverloadedStrings #-}
module FourPicsOneWord where
import           Control.Applicative
import qualified Data.Text            as T
import           Network.HTTP.Conduit (simpleHttp)
import           Text.HTML.DOM        (parseLBS)
import           Text.XML.Cursor
import Data.List

dictSource :: String -> String
dictSource n
  = "http://www.poslarchive.com/math/scrabble/lists/common-"
    ++ case n of
           (h : _) | h `elem` "5678" -> [h]
           _ -> "234"
    ++ ".html"

extractDict :: String -> IO [String]
extractDict url
  = do cont <- simpleHttp url
       let (wordsCursor:_) = fromDocument (parseLBS cont) $// element "pre" >=> child
           wordsText   = T.concat . content $ wordsCursor
       return $ T.unpack <$> (T.lines >=> T.words) wordsText

filteredResults :: String -> String -> IO [String]
filteredResults n l = filter (null . (\\ l))<$> extractDict (dictSource n)
