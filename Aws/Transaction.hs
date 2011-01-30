{-# LANGUAGE MultiParamTypeClasses, FunctionalDependencies #-}
module Aws.Transaction
where
  
import           Aws.Credentials
import           Aws.Query
import           Aws.Response
import qualified Data.Enumerator         as En
import qualified Network.HTTP.Enumerator as HTTP

class (AsQuery r, ResponseIteratee a)
    => Transaction r a | r -> a, a -> r

transact :: (Transaction r a) 
            => TimeInfo -> Credentials -> Info r -> r -> IO a
transact ti cr i r = do
  q <- signQuery ti cr $ asQuery i r
  let httpRequest = queryToHttpRequest q
  En.run_ $ HTTP.httpRedirect httpRequest responseIteratee
