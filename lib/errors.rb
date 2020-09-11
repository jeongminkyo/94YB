module Errors
  # format : [code, message]
  # 기본 에러 셋
  UNAUTHORIZED_ERROR = [401, "권한이 없습니다. \n관리자에게 문의하세요"]
  BAD_REQUEST = [400, '요청에 실패했습니다.']
  NOT_FOUND = [404, '']
  INVALID_PARAMETER = [400, '요청에 실패했습니다.']
  NBT_BLACK_USER = [400, '요청에 실패했습니다.']
  FORBIDDEN = [403, '']

  # custom http status code 500
  INTERNAL_SERVER_ERROR = [500, '알 수 없는 오류가 발생했습니다.']


  INVALID_SERVICE_PARAMETER = [1110, '요청에 실패했습니다.']
  VALIDATION_FAILED = [1111, '인증에 실패했습니다.']
end