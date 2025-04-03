from generateJWT import JWTGenerator
from datetime import timedelta
import argparse
import logging
import sys
import requests
logger = logging.getLogger(__name__)
def get_token(account:str, user:str, private_key_file_path:str, endpoint:str, role:str, lifetime:int=59, renewal_delay:int=54, endpoint_path:str='/', snowflake_account_url:str=None):
  token = _get_token(account, user, private_key_file_path, lifetime, renewal_delay)
  snowflake_token = token_exchange(token,endpoint=endpoint, role=role,
                  snowflake_account_url=snowflake_account_url,
                  snowflake_account=account)
  return snowflake_token

def _get_token(account, user, private_key_file_path, lifetime, renewal_delay):
  token = JWTGenerator(account, user, private_key_file_path, timedelta(minutes=lifetime),
            timedelta(minutes=renewal_delay)).get_token()
  logger.info("Key Pair JWT: %s" % token)
  return token

def token_exchange(token, role, endpoint, snowflake_account_url, snowflake_account):
  scope_role = f'session:role:{role}' if role is not None else None
  scope = f'{scope_role} {endpoint}' if scope_role is not None else endpoint
  data = {
    'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
    'scope': scope,
    'assertion': token,
  }
  logger.info(data)
  url = f'https://{snowflake_account}.snowflakecomputing.com/oauth/token'
  if snowflake_account_url:
    url =       f'{snowflake_account_url}/oauth/token'
  logger.info("oauth url: %s" %url)
  response = requests.post(url, data=data)
  logger.info("snowflake jwt : %s" % response.text)
  assert 200 == response.status_code, "unable to get snowflake token"
  return response.text