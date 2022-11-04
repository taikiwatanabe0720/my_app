require 'httparty'
require 'time'
require 'json/jwt'

module SendLineMessage
  # jwtを取得する
  # kidは公開鍵を登録した後発行されたものを使う
  # issとsubはチャネルIDを使う
  def self.get_jwt
    header = {
      alg: "RS256",
      typ: "JWT",
      kid: "69339067-98da-444b-a5ee-5a2514ca1700"
    }

    payload = {
      "iss": "1657146157",
      "sub": "1657146157",
      "aud": "https://api.line.me/",
      "exp": Time.now.to_i + 1800,
      "token_exp": 60 * 60 * 24 * 30
    }
    jwk = {
      "alg": "RS256",
      "d": "HfKHZeyADBibOP4U0MyiOFf26fzEdi4y571xUkSWJmNsYSs-FoQi85Ap5CiRMmgotllLG4I-JsVudSrstaDr-SOmWXbO6HSKEUa5xiDNoTh-Ys9CCQ48K0-tyFToUIh6PTV-Ccc0xZfN0ynE23W9N1VEyJYZCxC5flYFCQyDJRN8nVoyP5Y2HmNFrfVmvc6UScyLTk8GDyiQB0rmBNzPbPfyqxgO7YjglEHriRwGvrAqyO5jmIaB2oD5Lzqx_ZY5twQvcAVA3Ir03T5HqFRdzG-QMsWxoOMRiuTou29_vO4e0iJ_lra8z41n_PtdMYiZH3qT07rfwQ06C1hUTByiHQ",
      "dp": "OIwBE05K3jYJBH2scumH1qcqZr2WN7V0UU54g61yeLDMlrMlfFTEtV_08AmIcYAmkfXAL4-bk6g2Jo2tEbx5QjrAzYkyRMRNXFLjM7yqLkDhG8haL0KqimGMFGlMH6P8kCRJFzupiFLMI6-afx_OLy4LJ-eAN3dDmIWFuv6UpdU",
      "dq": "wzSgVO9QAcn9vQJu4sIOXQhBDPDZOAaY2sturC-WHQ_S2wbl45yIrTbkVjYNmRj05brE7DZjgSX5LddiuIOy7TGwOApYYqg5Pu4VLK-jYhLmBNsT1CxhQ1pZr0H80CDMZzxgwMx4aREltEdoMlgODlqp88wpt8_eshwp8_zN-l8",
      "e": "AQAB",
      "ext": true,
      "key_ops": [
        "sign"
      ],
      "kty": "RSA",
      "n": "uP_pbMDl7er9dOUvuic2Y7YklKLLfanIsQeHuhFV87s_KefNqHXKws7VRdIKQTuznX_nBSwgW_mowjw6BeEBw1OyOvRancBnnJoGoeGKoUp7MXukBbOJOA0nQrBowszWgx5QVjlY5Em6hxKOi0ud9a8Ru32jalZaLU4ktD5bltyCiPSMTz9h3DedPmx0EsenIqWRz6ufQaADJ4cA0U8fqBv9pnPq9zPcDJcjNjLqHZ50bHfTgrsN6OafS1YiQxezfU6-c_vl8Zxvg6BItMmi-Pv0QKt54Pye1NJD7aszHfyyUEYcqySDy4ptmw3fzfsLF1abrSSH7Do-lVuf89pwrQ",
      "p": "5QO6QRr1ych9tuQDbShyqqaiJ2xh6jn3DtHt32DiYxXR_MS9tKtArLPAl9knUDePpdSv4FtMtzFbAk6WiMXcerNSHFFgDwm_Rjaacfcrze41StoYOu1keU877Pl1fpgAklE1Ph8VKsBApfrYdh4D-HknvTfYv_vfN6wwexW7KF8",
      "q": "zsx3IuMys4wUVtHUdomuiDb660vZa1TEEpLFSCZx5MEFUBOrHI8unZJaX8JOqciMZQUQTekl13oQrRPR7vPTypqAIiRtDamix6oKz-Wl_DXpnIfzQFZLkf03FOaL3u8yctqrYiAXqQFjtPzccIr6aThiSJnDrG6VG0-2xX5TcnM",
      "qi": "3P6F17Vws6WCfVlrMLTO655Gzd_e7FpFpuvJqU0RbT5ilxZ9a51Dl47nQkDSs1DFG5z8bxNF2V0wkEoebXIl3PreRdJQ4eGIYnFzXGWTkSATs7rA_ajiG0WXviNHyjWhzX9zIeRniKMagz496QMjpvwZH5u_t4FSktEFni0AuTE"
    }
    
    #jwk = JSON.parse(pri_key)
    jwt_nonsig = JSON::JWT.new(payload)
    jwt_nonsig.header = header
    private_key = JSON::JWK.new(jwk).to_key

    jwt = jwt_nonsig.sign(private_key).to_s
    return jwt
  end

  # access_tokenを取得する
  def self.get_access_token(jwt)
    url = "https://api.line.me/oauth2/v2.1/token"
    headers = {"Content-Type"=>"application/x-www-form-urlencoded"}
    query = {"grant_type"=>"client_credentials", "client_assertion_type"=>"urn:ietf:params:oauth:client-assertion-type:jwt-bearer", "client_assertion"=>jwt}
    result = HTTParty.post(url, :headers=>headers, :query=>query)
    return result
  end

  # メッセージを送信する
  def self.send_message(access_token, to_user_id, message)
    url = "https://api.line.me/v2/bot/message/push"
    headers = {"Content-Type"=>"application/json", "Authorization"=>"Bearer #{access_token}", "X-Line-Retry-Key"=>SecureRandom.uuid}
    body = {"to": to_user_id, "messages":[{"type": "text", "text": message}]}
    result = HTTParty.post(url, :headers=>headers, :body=>body.to_json)
    return result
  end

  def self.exec(message=nil)
    begin
      jwt = get_jwt
      puts "jwt作成成功"
      puts jwt
    rescue => e
      puts "jwt作成に失敗しました"
      puts e
    end

    begin
      result = get_access_token(jwt)
      puts "access_token取得成功"
      puts result["access_token"]
    rescue => e
      puts "access_token取得に失敗しました"
      puts e
    end

    begin
      to_user_id = "Uefc77bca0a27815600291948ca3703b1"
      message = "テストメッセージです" if message.nil?
      result = send_message(result["access_token"], to_user_id, message)
      puts "メッセージ送信成功"
      puts result
    rescue => e
      puts "メッセージ送信失敗"
      puts e
    end
  end

end