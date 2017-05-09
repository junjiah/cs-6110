module Eval where

import           Data.List  (find)
import           Data.Maybe (fromJust)
import qualified Data.Set   as Set

import           Expr

freeVar :: Expr -> Set.Set Name
freeVar (Var n)           = Set.singleton n
freeVar (Lam n expr)      = Set.delete n (freeVar expr)
freeVar (App expr1 expr2) = Set.union (freeVar expr1) (freeVar expr2)

freshVar :: Set.Set Name -> Name
freshVar s = [notUsedChar]
  where notUsedChar = fromJust $ find (\c -> Set.notMember [c] s) ['a'..'z']

subst :: Name -> Expr -> Expr -> Expr
subst n v e@(Var n')
  | n == n'   = v
  | otherwise = e
subst n v (App expr1 expr2) = (App expr1' expr2')
  where expr1' = subst n v expr1
        expr2' = subst n v expr2
subst n v e@(Lam n' body)
  | n == n'                      = e
  | Set.notMember n' (freeVar v) = Lam n' (subst n v body)
  | otherwise                    =
    let newName = freshVar (Set.union (freeVar v) (freeVar e))
    in Lam newName (subst n v (subst n' (Var newName) body))
