class KakaoController < ApplicationController

  skip_before_filter :verify_authenticity_token

  USER_NAME_LIST = %w(민교 재혁 재룡 대훈 준수 태현 남욱 현종 용진 민석 채연 준배)
  def keyboard
    render json: { type: 'buttons', buttons: ['입금 계좌 확인', '납부 내역 확인'] }
  end

  def message
    result_hash = {}
    message = {}

    keyboard = { type: 'buttons', buttons: ['입금 계좌 확인', '납부 내역 확인'] }
    result_hash[:keyboard] = keyboard if params[:content] != '납부 내역 확인'

    if params[:content] == '입금 계좌 확인'
      message[:text] = '356-1100-0267-33 농협'
    elsif params[:content] == '납부 내역 확인'
      message[:text] = '이름을 입력하세요'
    elsif USER_NAME_LIST.include?(params[:content])
      user = User.where('display_name like ?', '%' + params[:content] + '%').first
      if user.present?
        user_histories = user.cashes
        if user_histories.present?
          message[:text] = ''
          user_histories.each do |history|
            text = history[:description].to_s + ' : ' + history[:money].to_s + '원' + "\n"
            message[:text] += text
          end
        else
          message[:text] = '납부 내역이 없습니다.'
        end
      else
        message[:text] = '아직 등록되지 않은 사용자입니다.'
      end
    else
      message[:text] = '잘못된 이름입니다. 다시 시도해주세요'
    end

    result_hash[:message] = message
    render json: result_hash
  end
end
