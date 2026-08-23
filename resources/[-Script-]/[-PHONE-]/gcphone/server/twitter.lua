function TwitterPostTweet(a, b, c, d, e)
    getUser(d, function(f)
        if f then
            MySQL.Async.fetchAll("INSERT INTO twitter_tweets (`authorId`, `message`, `image`, `realUser`) VALUES(@authorId, @message, @image, @realUser);", {
                ["@authorId"] = f.id,
                ["@message"] = a,
                ["@image"] = b,
                ["@realUser"] = d
            }, function()
                tweet = {}
                tweet["authorId"] = f.id;
                tweet["message"] = a;
                tweet["image"] = b
                tweet["realUser"] = d;
                tweet["time"] = os.date()
                tweet["author"] = f.author;
                tweet["authorIcon"] = f.authorIcon;
                MySQL.Async.fetchAll('SELECT avatar_url, vip FROM twitter_accounts WHERE identifier = @identifier', {
                    ['@identifier'] = d
                }, function(zz)
                    local customtext = ''
                    local avatar_url = ''

                    if zz[1].vip ~= nil then
                        if zz[1].vip == 1 then
                            customtext = '<div style="padding-top: 10px;"><i style="color: #4f9bff" class="fas fa-chess-queen"></i></div>&nbsp;&nbsp;'
                        else
                            customtext = ''
                        end
                    end

                    if zz[1].avatar_url ~= nil then
                        avatar_url = zz[1].avatar_url
                    else
                        avatar_url = ""
                    end

                    if string.match(b, '?') or string.match(b, 'png') or string.match(b, 'jpeg') or string.match(b, 'jpg') or string.match(b, 'pjg') or string.match(b, 'gif') then
                        TriggerClientEvent('chat:addMessage', -1, {
                        template = '<div style="display: flex; max-width: 40px; height: 8.3vw; margin-top: 0.3vw;"> <div style="display: flex; min-width:16.5vw ;min-height:3vw; height: auto; background: radial-gradient( circle, rgba( 25, 25, 25, 0.7 ) 0%, rgba( 25, 25, 25, 0.7 ) 50%, rgba( 19, 19, 19, 0.7 ) 100% );border-radius: 0.5vw;justify-content: space-between; "> <div style="height: 100%; display: flex;align-items: center;padding:0 0.3vw;"> <div style="display: flex; width: 2vw;height: 2vw; margin-top: -5vw; border: 0.155vw solid rgb( 238, 174, 215 );filter: drop-shadow( 0 0 0.1vw rgb( 238, 174, 215) ); border-radius: 100vw; justify-content: center;align-items: center; "> <div style="width: 90%;height:90% ; background-image: url( '..zz[1].avatar_url..' ); background-size: 299%;background-position: 26% 60%;overflow: hidden;background-repeat: no-repeat;image-rendering: pixelated;border-radius: 100vw;box-shadow: rgba( 0, 0, 0, 0.1 ) 0px -23px 25px 0px inset, rgba( 255, 255, 255, 0.15 ) 0px -36px 30px 0px inset, rgba( 255, 255, 255, 0.1 ) 0px -79px 40px 0px inset, rgba( 255, 255, 255, 0.06 ) 0px 2px 1px, rgba( 0, 0, 0, 0.09 ) 0px 4px 2px, rgba( 0, 0, 0, 0.09 ) 0px 8px 4px, rgba( 0, 0, 0, 0.09 ) 0px 16px 8px, rgba( 0, 0, 0, 0.09 ) 0px 32px 16px;"></div> </div> </div> <div style="display: flex;width: 100%; flex-direction: column; position: relative; justify-content: center;"> <div style="display: flex;justify-content: space-between; width: 100%;height: 1.3vw;align-items: center;"> <span style="color: rgb( 238, 174, 215 ); font-weight: bolder;font-size: 0.6vw; filter: drop-shadow( 0 0 0.05vw );"><i class="fa-brands fa-twitter" style="padding-right: 0.2vw;font-size: 0.5vw;"></i>{0}</span><span style="color: white; padding:0 0.5vw;font-size: 0.5vw; font-weight: bolder;">[ '..os.date( '%H:%M' ).. ']</span> </div> <div style="width: 12vw;height: 7vw;border-radius: 0.5vw; margin-left: 0.8vw; display: flex;margin-bottom: 0.3vw;background-position: center;background-size: cover; background-image: url( '..b..' );"></div> </div> </div> </div>',
                        args = {tweet['author'], a}
                        })
                    
						local xPlayer = ESX.GetPlayerFromIdentifier(d)
						local sendToDiscord = '' .. xPlayer.name .. ' : โพสต์ทวิตเตอร์ : ' .. a .. ' : และรูป : ' .. b .. ''
						TriggerEvent('azael_dc-serverlogs:insertData', 'twitter', sendToDiscord, xPlayer.source, '^5')
					else
                        TriggerClientEvent('chat:addMessage', -1, {
                        template = '<div style="display: flex; max-width: auto; height: auto; margin-top: 0.3vw;"> <div style="display: flex; min-width:12vw ;min-height:3vw; height: auto; background: radial-gradient( circle, rgba( 25, 25, 25, 0.7 ) 0%, rgba( 25, 25, 25, 0.7 ) 50%, rgba( 19, 19, 19, 0.7 ) 100% );border-radius: 0.5vw;justify-content: space-between; "> <div style="height: 100%; display: flex;align-items: center;padding:0 0.3vw;"> <div style="display: flex; width: 2vw;height: 2vw; border: 0.155vw solid rgb( 238, 174, 215 );filter: drop-shadow( 0 0 0.1vw rgb( 238, 174, 215) ); border-radius: 100vw; justify-content: center;align-items: center; "> <div style="width: 90%;height:90% ;  background-image: url( '..zz[1].avatar_url..' ); background-size: 299%;background-position: 26% 60%;overflow: hidden;background-repeat: no-repeat;image-rendering: pixelated;border-radius: 100vw;box-shadow: rgba( 0, 0, 0, 0.1 ) 0px -23px 25px 0px inset, rgba( 255, 255, 255, 0.15 ) 0px -36px 30px 0px inset, rgba( 255, 255, 255, 0.1 ) 0px -79px 40px 0px inset, rgba( 255, 255, 255, 0.06 ) 0px 2px 1px, rgba( 0, 0, 0, 0.09 ) 0px 4px 2px, rgba( 0, 0, 0, 0.09 ) 0px 8px 4px, rgba( 0, 0, 0, 0.09 ) 0px 16px 8px, rgba( 0, 0, 0, 0.09 ) 0px 32px 16px;"></div> </div> </div> <div style="display: flex;width: 100%; flex-direction: column; position: relative; justify-content: center;"> <div style="display: flex;justify-content: space-between; width: 100%;height: 1.3vw;align-items: center;"> <span style="color: rgb( 238, 174, 215 ); font-weight: bolder;font-size: 0.6vw; filter: drop-shadow( 0 0 0.05vw );"><i class="fa-brands fa-twitter" style="padding-right: 0.2vw;font-size: 0.5vw;"></i>{0}</span><span style="color: white; padding:0 0.5vw;font-size: 0.5vw; font-weight: bolder;">[' ..os.date( '%H:%M' ).. ']</span> </div> <span style="padding:0 0.5vw;  word-wrap: break-word; overflow-wrap: break-word; font-size: 0.7vw;color: white; max-width: 15vw;">{1}</span> </div> </div></div>',
                        args = {tweet['author'], a}
                        })
                    
						local xPlayer = ESX.GetPlayerFromIdentifier(d)
						local sendToDiscord = '' .. xPlayer.name .. ' : โพสต์ข้อความทวิตเตอร์ : ' .. a .. ''
						TriggerEvent('azael_dc-serverlogs:insertData', 'twitter', sendToDiscord, xPlayer.source, '^2')
					end
                end)
                TriggerEvent("gcPhone:twitter_newTweets", tweet)
                TriggerClientEvent("gcPhone:twitter_newTweets", -1, tweet)
                -- pcall(function()
                    -- exports['azael_dc-serverlogs']:insertData({
                        -- event = 'twitter',
                        -- content = ('ข้อความ: %s'):format((message or a)),
                        -- image = (image or b),
                        -- source = (sourcePlayer or c),
                        -- color = 5
                    -- })
                -- end)
            end)
        end
    end)
end



function TwitterGetTweets(a, b) 
  if a == nil then 
    MySQL.Async.fetchAll([===[SELECT twitter_tweets.*, twitter_accounts.username as author, twitter_accounts.avatar_url as authorIcon FROM twitter_tweets LEFT JOIN twitter_accounts ON twitter_tweets.authorId = twitter_accounts.id ORDER BY time DESC LIMIT 30]===], {}, b) else 
      MySQL.Async.fetchAll([===[SELECT twitter_tweets.*, twitter_accounts.username as author, twitter_accounts.avatar_url as authorIcon, twitter_likes.id AS isLikes FROM twitter_tweets LEFT JOIN twitter_accounts ON twitter_tweets.authorId = twitter_accounts.id LEFT JOIN twitter_likes ON twitter_tweets.id = twitter_likes.tweetId AND twitter_likes.authorId = @accountId ORDER BY time DESC LIMIT 30]===], {["@accountId"] = a}, b) 
    end 
  end


function TwitterGetFavotireTweets(accountId, cb)
    MySQL.Async.fetchAll([===[
      SELECT twitter_tweets.*,
        twitter_accounts.username as author,
        twitter_accounts.avatar_url as authorIcon
      FROM twitter_tweets
        LEFT JOIN twitter_accounts
          ON twitter_accounts.identifier = @accountId
      WHERE realUser = @accountId ORDER BY TIME DESC LIMIT 30
    ]===]
        
        
        
        
        
        
        
        , {['@accountId'] = accountId}, cb)
end

function getUser(identifier, cb)
    MySQL.Async.fetchAll("SELECT id, username as author, avatar_url as authorIcon FROM twitter_accounts WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    }, function(data)
        cb(data[1])
    end)
end


function TwitterToogleLike(identifier, tweetId, sourcePlayer)
    getUser(identifier, function(user)
        MySQL.Async.fetchAll('SELECT * FROM twitter_tweets WHERE id = @id', {
            ['@id'] = tweetId
        }, function(tweets)
            if (tweets[1] == nil) then return end
            local tweet = tweets[1]
            MySQL.Async.fetchAll('SELECT * FROM twitter_likes WHERE authorId = @authorId AND tweetId = @tweetId', {
                ['authorId'] = user.id,
                ['tweetId'] = tweetId
            }, function(row)
                if (row[1] == nil) then
                    MySQL.Async.insert('INSERT INTO twitter_likes (`authorId`, `tweetId`) VALUES(@authorId, @tweetId)', {
                        ['authorId'] = user.id,
                        ['tweetId'] = tweetId
                    }, function()
                        MySQL.Async.execute('UPDATE `twitter_tweets` SET `likes`= likes + 1 WHERE id = @id', {
                            ['@id'] = tweet.id
                        }, function()
                            TriggerClientEvent('gcPhone:twitter_updateTweetLikes', -1, tweet.id, tweet.likes + 1)
                            TriggerClientEvent('gcPhone:twitter_setTweetLikes', sourcePlayer, tweet.id, true)
                            TriggerEvent('gcPhone:twitter_updateTweetLikes', tweet.id, tweet.likes + 1)
                        end)
                    end)
                else
                    MySQL.Async.execute('DELETE FROM twitter_likes WHERE id = @id', {
                        ['@id'] = row[1].id,
                    }, function()
                        MySQL.Async.execute('UPDATE `twitter_tweets` SET `likes`= likes - 1 WHERE id = @id', {
                            ['@id'] = tweet.id
                        }, function()
                            TriggerClientEvent('gcPhone:twitter_updateTweetLikes', -1, tweet.id, tweet.likes - 1)
                            TriggerClientEvent('gcPhone:twitter_setTweetLikes', sourcePlayer, tweet.id, false)
                            TriggerEvent('gcPhone:twitter_updateTweetLikes', tweet.id, tweet.likes - 1)
                        end)
                    end)
                end
            end)
        end)
    end)
end

function TwitterToogleDelete(identifier, tweetId, sourcePlayer)
    MySQL.Async.execute('DELETE FROM twitter_tweets WHERE id = @id', {
        ['@id'] = tweetId,
    }, function()
        TwitterGetFavotireTweets(identifier, function(tweets)
            TriggerClientEvent('gcPhone:twitter_getFavoriteTweets', sourcePlayer, tweets)
        end)
    end)
end

function TwitterShowError(sourcePlayer, title, message)
    TriggerClientEvent('gcPhone:twitter_showError', sourcePlayer, message)
end

function TwitterShowSuccess(sourcePlayer, title, message)
    TriggerClientEvent('gcPhone:twitter_showSuccess', sourcePlayer, title, message)
end

RegisterServerEvent('gcPhone:twitter_login')
AddEventHandler('gcPhone:twitter_login', function(source, identifier)
    local sourcePlayer = tonumber(source)
    getUser(identifier, function(user)
        if user ~= nil then
            TriggerClientEvent('gcPhone:twitter_setAccount', sourcePlayer, user.author, user.authorIcon)
        end
    end)
end)

RegisterServerEvent('gcPhone:twitter_changeUsername')
AddEventHandler('gcPhone:twitter_changeUsername', function(newUsername)
    local sourcePlayer = tonumber(source)
    local identifier = getPlayerID(source)
    getUser(identifier, function(user)
        MySQL.Async.execute("UPDATE `twitter_accounts` SET `username`= @newUsername WHERE identifier = @identifier", {
            ['@identifier'] = identifier,
            ['@newUsername'] = newUsername
        }, function(result)
            if (result == 1) then
                TriggerClientEvent('gcPhone:twitter_setAccount', sourcePlayer, newUsername, user.authorIcon)
            end
        end)
    end)
end)

RegisterServerEvent('gcPhone:twitter_setAvatarUrl')
AddEventHandler('gcPhone:twitter_setAvatarUrl', function(avatarUrl)
    local sourcePlayer = tonumber(source)
    local identifier = getPlayerID(source)
    getUser(identifier, function(user)
        MySQL.Async.execute("UPDATE `twitter_accounts` SET `avatar_url`= @avatarUrl WHERE identifier = @identifier", {
            ['@identifier'] = identifier,
            ['@avatarUrl'] = avatarUrl
        }, function(result)
            if (result == 1) then
                TriggerClientEvent('gcPhone:twitter_setAccount', sourcePlayer, user.author, avatarUrl)
            end
        end)
    end)
end)


RegisterServerEvent('gcPhone:twitter_getTweets')
AddEventHandler('gcPhone:twitter_getTweets', function()
    local sourcePlayer = tonumber(source)
    if username ~= nil and username ~= "" and password ~= nil and password ~= "" then
        getUser(username, password, function(user)
            local accountId = user and user.id
            TwitterGetTweets(accountId, function(tweets)
                TriggerClientEvent('gcPhone:twitter_getTweets', sourcePlayer, tweets)
            end)
        end)
    else
        TwitterGetTweets(nil, function(tweets)
            TriggerClientEvent('gcPhone:twitter_getTweets', sourcePlayer, tweets)
        end)
    end
end)

RegisterServerEvent('gcPhone:twitter_getFavoriteTweets')
AddEventHandler('gcPhone:twitter_getFavoriteTweets', function()
    local sourcePlayer = tonumber(source)
    local srcIdentifier = getPlayerID(source)
    TwitterGetFavotireTweets(srcIdentifier, function(tweets)
        TriggerClientEvent('gcPhone:twitter_getFavoriteTweets', sourcePlayer, tweets)
    end)
end)

RegisterServerEvent('gcPhone:twitter_postTweets')
AddEventHandler('gcPhone:twitter_postTweets', function(message, image)
    local sourcePlayer = tonumber(source)
    local srcIdentifier = getPlayerID(source)
    TwitterPostTweet(message, image, sourcePlayer, srcIdentifier)
end)

RegisterServerEvent('gcPhone:twitter_toogleLikeTweet')
AddEventHandler('gcPhone:twitter_toogleLikeTweet', function(tweetId)
    local sourcePlayer = tonumber(source)
    local srcIdentifier = getPlayerID(source)
    TwitterToogleLike(srcIdentifier, tweetId, sourcePlayer)
end)

RegisterServerEvent('gcPhone:twitter_toggleDeleteTweet')
AddEventHandler('gcPhone:twitter_toggleDeleteTweet', function(tweetId)
    local sourcePlayer = tonumber(source)
    local srcIdentifier = getPlayerID(source)
    TwitterToogleDelete(srcIdentifier, tweetId, sourcePlayer)
end)


--[[
Discord WebHook
set discord_webhook 'https//....' in config.cfg
--]]
function sendDiscordTwitter(tweet)
    local discord_webhook = GetConvar('twitter_discord_webhook', '')
    if discord_webhook == '' then
        return
    end
    local headers = {
        ['Content-Type'] = 'application/json'
    }
    local data = {
        ["username"] = tweet.author,
        ["embeds"] = {{
            ["thumbnail"] = {
                ["url"] = tweet.authorIcon
            },
            ["color"] = 1942002
        }}
    }
    if tweet.image ~= "" then
        data['embeds'][1]['image'] = {['url'] = tweet.image}
    end
    tweet.message = tweet.message:gsub("{{{", ":")
    tweet.message = tweet.message:gsub("}}}", ":")
    data['embeds'][1]['description'] = tweet.message
    PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end

AddEventHandler('gcPhone:twitter_newTweets', function (tweet)
  -- print(json.encode(tweet))
  local discord_webhook = GetConvar('discord_webhook', '')
  if discord_webhook == '' then
    return
  end
  local headers = {
    ['Content-Type'] = 'application/json'
  }
  local data = {
    ["username"] = tweet.author,
    ["embeds"] = {{
      ["thumbnail"] = {
        ["url"] = tweet.authorIcon
      },
      ["color"] = 1942002,
      ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ", tweet.time / 1000 )
    }}
  }
	if tweet.image ~= "" then
		data['embeds'][1]['image'] = {['url'] = tweet.image}
	end
	tweet.message = tweet.message:gsub("{{{", ":")
	tweet.message = tweet.message:gsub("}}}", ":")
	data['embeds'][1]['description'] = tweet.message
  local isHttp = string.sub(tweet.message, 0, 7) == 'http://' or string.sub(tweet.message, 0, 8) == 'https://'
  local ext = string.sub(tweet.message, -4)
  local isImg = ext == '.png' or ext == '.pjg' or ext == '.gif' or string.sub(tweet.message, -5) == '.jpeg'
  if (isHttp and isImg) and true then
    data['embeds'][1]['image'] = { ['url'] = tweet.message }
  else
    data['embeds'][1]['description'] = tweet.message
  end
  PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)
