# Config

# Local nodejs binary
node_bin = "/Users/jodus/.config/fnm/bin/node"

# Your personal API token from https://cryptopanic.com/about/api/
cryptopanic_api_token = ""

# List of crypto names to show price for
price_crypto_names = "bitcoin,ethereum,monero"

# List of crypto codes to show price for
news_crypto_codes = "ETH,BTC,LTC,XRP,XMR,ZRX,LEND,REQ"

bar =
  width: "100%"

  gap:
    horizontal: 10
    bottom: 7

  colors:
    front: "#abb2bf"
    background: "#282c34"
    black: "#282c34"
    white: "#abb2bf"
    grey: "#5c6370"
    red: "#be5046"
    green: "#98c379"
    yellow: "#e5c07b"
    blue: "#61afef"
    cyan: "#56b6c2"
    magenta: "#c678dd"

  animation:
    duration: 120 # Time it takes to scroll all the news in seconds


# Script
#############################################################################
barHeight = "25px"
barWidth = "calc(100% - #{bar.gap.horizontal * 2}px)"

style: """
  width: #{barWidth}
  height: #{barHeight}
  left: #{bar.gap.horizontal}px
  bottom: #{bar.gap.bottom}px
  color: #{bar.colors.front}
  background-color: #{bar.colors.background}
  z-index: 100
  overflow: hidden
  -webkit-transform:translate3d(0,0,0)
  display: flex

  font-size: 14px
  font-family: 'Helvetica'
  font-weight: bold

  div
    height: #{barHeight}
    line-height: #{barHeight}

  @-webkit-keyframes ticker
    0%
      transform: translateX(0)
      visibility: visible
    100%
      transform: translateX(-100%)

  @keyframes ticker
    0%
      transform: translateX(0)
      visibility: visible
    100%
      transform: translateX(-100%)

  .posts-wrap
    width: 100%
    padding-left: 100%

  .posts
    display: inline-block
    white-space: nowrap
    padding-right: 100%
    
    -webkit-transform-style: preserve-3d;
    animation-iteration-count: infinite
    animation-timing-function: linear
    animation-name: ticker
    animation-duration: #{bar.animation.duration}s
    
  .post
    display: inline-block
    padding: 0 50px
    color: white
    text-decoration: none
    
    .coins
      color: #{bar.colors.grey}
      margin-right: 5px

  .pad
    z-index: 20
    position: absolute
    background: #{bar.colors.background}

  .prices
    right: 0
    padding: 0 15px
    border-left: 2px solid #{bar.colors.grey}

    .price
      margin-left: 30px
    .price:first-of-type
      margin-left: 0

    .up, .down
      margin: 0 2px
    .up
      color: #{bar.colors.green}
    .down
      color: #{bar.colors.red}

  .error-overlay
    background: #{bar.colors.background}
    color: #{bar.colors.grey}
    z-index: 100
    position: absolute
    height: 100%
    width: 100%
    text-align: center
"""

command: "CRYPTOPANIC_API_TOKEN=#{cryptopanic_api_token} NEWS_CURRENCIES=#{news_crypto_codes} PRICE_CURRENCIES=#{price_crypto_names} #{node_bin} cryptobar/commands/update"

refreshFrequency: bar.animation.duration * 1000

render: (output) ->
  @run("bar/install")
  """
    <link rel="stylesheet" href="cryptobar/node_modules/cryptocoins-icons/webfont/cryptocoins.css" />
    <link rel="stylesheet" href="cryptobar/assets/font-awesome/css/font-awesome.min.css" />

    <div class='pad left-pad'></div>

    <div class='pad prices'>
    </div>

    <div class='posts-wrap'>
      <div>
      </div>
    </div>

    <div class='error-overlay'>Stopped</div>
  """

update: (output, el) ->
  if output == "ERROR"
    $(".error-overlay").show()
    @showError()
  else
    $(".error-overlay").hide()
    [news, prices] = output.split("||")
    @addPrices(prices)
    @addNews(news)

showError: () ->
  $("")

addNews: (news, el) ->
  $(".posts", el).removeClass("posts")
  posts = news
    .split("@@")
    .map(@getPostFromStr)
    .map(({coins, title, url}) => """
      <a href="#{url}" class='post'>
        <span class='coins'>#{coins}</span>
        #{title}
      </a>""")
  $(".posts-wrap > div", el)
    .empty()
    .append(posts)
    .addClass("posts")

getPostFromStr: (str) =>
  try
    data = str.match(/^\[(.*)\]\ \[(.*)\]\ (.*)$/)
    return { coins: data[1], url: data[2], title: data[3] }
  catch e
    return { title: e }

addPrices: (prices) ->
  prices = prices
    .split("@@")
    .map(@getPriceFromStr)
    .map(({icon, change24h, price}) => """
      <span class='price'>
        <span class='cc #{icon}'></span>
        <span class='fa #{if parseFloat(change24h) > 0 then 'up fa-caret-up' else 'down fa-caret-down'}'>
        </span>
        #{price}
      </span>""")
  $(".prices", el)
    .empty()
    .append(prices)

getPriceFromStr: (str) =>
  try
    data = str.match(/^\[(.*)\]\ \[(.*)\]\ (.*)$/)
    return { icon: data[1], change24h: data[2], price: data[3] }
  catch e
    return { title: e }
