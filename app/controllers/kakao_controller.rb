class KakaoController < ApplicationController

  def keyboard
    render json: { type: 'buttons', button: ['입금 계좌 확인', '납부 내역 확인'] }
  end
end
