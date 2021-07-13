{-# LANGUAGE OverloadedStrings #-}

import Hakyll

--------------------------------------------------------------------------------

main :: IO ()
main = hakyll $ do
  match "images/*" $ do
    route   idRoute
    compile copyFileCompiler

  match "css/*" $ do
    route   idRoute
    compile compressCssCompiler

  match (fromList ["about.rst", "contact.markdown"]) $ do
    route   $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/default.html" defaultContext
      >>= relativizeUrls

  match "posts/*" $ do
    route   $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/post.html"    postCtx
      >>= loadAndApplyTemplate "templates/default.html" postCtx
      >>= relativizeUrls

  create ["archive.html"] $ do
    route   idRoute
    compile $ do
      let archiveCtx = listCtx "Archives"
      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls

  match "index.html" $ do
    route   idRoute
    compile $ do
      let indexCtx = listCtx "Home"
      getResourceBody
        >>= applyAsTemplate indexCtx
        >>= loadAndApplyTemplate "templates/default.html" indexCtx
        >>= relativizeUrls

  match "templates/*" $ compile templateBodyCompiler

  match "four/*" $ do
    route   idRoute
    compile copyFileCompiler

--------------------------------------------------------------------------------

postCtx :: Context String
postCtx =
     dateField "date" "%B %e, %Y"
  <> defaultContext

listCtx :: String -> Context String
listCtx title =
     listField "posts" postCtx (recentFirst =<< loadAll "posts/*")
  <> constField "title" title
  <> defaultContext