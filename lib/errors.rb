module Errors
  # format : [code, message]
  # 기본 에러 셋
  UNAUTHORIZED_ERROR = [401, '']
  BAD_REQUEST = [400, '요청에 실패했습니다.']
  NOT_FOUND = [404, '']
  INVALID_PARAMETER = [400, '요청에 실패했습니다.']
  NBT_BLACK_USER = [400, '요청에 실패했습니다.']
  FORBIDDEN = [403, '']

  # custom http status code 500
  INTERNAL_SERVER_ERROR = [500, '']
  # internal server error 가 500이면 server error 클래스가 하나 있어야함.
end