{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE GADTs                 #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeApplications      #-}

module Language.Metro.Render
    ( render
    ) where

import           Data.Text                  (Text)
import           Polysemy

import           Language.Metro.NodeProc
import           Language.ECMAScript.Syntax (Program)

data Render
instance Message Render Program Text

render :: Member NodeProc r => Program -> Sem r Text
render = send' @Render
