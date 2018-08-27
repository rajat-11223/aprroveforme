module StripeHelpers
  def fill_stripe_element(card, exp, cvc, postal='')
    card_iframe = all('iframe')[0]

    within_frame card_iframe do
      fill_by_char card, find_field('cardnumber')

      fill_by_char exp, find_field('exp-date')

      fill_by_char cvc, find_field('cvc')

      fill_by_char postal, find_field('postal')
    end
  end

  private

  def fill_by_char(text, field)
    text.chars.each do |piece|
      field.send_keys(piece)
    end
  end
end
