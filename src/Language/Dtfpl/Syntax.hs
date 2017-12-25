module Language.Dtfpl.Syntax
    ( A (..)
    , A'
    , AProg
    , Prog (..)
    , Decl (..)
    , DefAlt (..)
    , Pat (..)
    , Expr (..)
    , Ident (..)
    , Literal (..)
    ) where

data A n a = A { node :: n, ann :: a } deriving Show

type A' n a = A (n a) a

type AProg a = A' Prog a

data Prog a
    = Prog [A' Decl a]
    deriving Show

data Decl a
    = Def (A Ident a) [A' DefAlt a]
    | Let (A Ident a) (A' Expr a)
    deriving Show

data DefAlt a
    = DefAlt [A' Pat a] (A' Expr a)
    deriving Show

data Pat a
    = VarPat (A Ident a)
    | LitPat (A Literal a)
    deriving Show

data Expr a
    = VarExpr (A Ident a)
    | LitExpr (A Literal a)
    | App (A' Expr a) (A' Expr a)
    | If (A' Expr a) (A' Expr a) (A' Expr a)
    deriving Show

data Ident
    = Ident String
    deriving Show

data Literal
    = NumLit Double
    | StrLit String
    deriving Show
