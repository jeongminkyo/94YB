class KakaoController < ApplicationController

  USER_NAME_LIST = %w(민교 재혁 재룡 대훈 준수 태현 남욱 현종 용진 민석 채연)
  def keyboard
    render json: { type: 'buttons', buttons: ['입금 계좌 확인', '납부 내역 확인'] }
  end

  def message
    result_hash = {}
    message = {}

    keyboard = { type: 'buttons', buttons: ['입금 계좌 확인', '납부 내역 확인'] }
    result_hash[:keyboard] = keyboard if params[:context] != '납부 내역 확인'

    if params[:content] == '입금 계좌 확인'
      message[:text] = '356-1100-0267-33 농협'
    elsif params[:context] == '납부 내역 확인'
      message[:text] = '이름을 입력하세요'
    elsif USER_NAME_LIST.include?(params[:context])
      user = User.where('display_name like ?', '%' + params[:context] + '%')
      message[:text] = IncomeHistory.user_income_history(user).to_json(:except => :id)
    else
      message[:text] = '잘못된 이름입니다. 다시 시도해주세요'
    end

    render json: result_hash
  end
end
