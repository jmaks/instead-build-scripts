-- $Name:INSTEAD Lines$
-- $Name(ru):Шарики INSTEAD$
-- $Version:1.0$
instead_version "1.4.0"
require "sprites"
require "timer"
require "click"
require "prefs"
require "sound"
require "kbd"

dofile "board.lua"
dofile "gfx.lua"

game.enable_save = false

click.bg = true
click.press = true
click.button = true

timer_ticks = 0

function init()
	hook_keys("left", "right", "up", "down", "return");

	set_music 'snd/satellite.s3m'
	if not prefs.hiscores then
		prefs.hiscores = { 50, 40, 30, 20, 10 }
	end
	load_font()
	load_bg()
	load_balls()
	load_cell()
	load_menu()
	load_music()
	load_info()
	load_volume()

	gameover_snd = sound.load 'snd/gameover.wav'
	hiscore_snd = sound.load 'snd/hiscore.wav'
	boom_snd = sound.load 'snd/boom.wav'
	paint_snd = sound.load 'snd/paint.wav'
	fadeout_snd = sound.load 'snd/fadeout.wav'
	bonus_snd = sound.load 'snd/bonus.wav'

	sprite.draw(bg, sprite.screen(), 0, 0)
	good_luck = sprite.text(font, "Good Luck!", 'white');
	main.nam = img(sprite.text(font, "INSTEAD Lines", 'white'));
	restart = sprite.text(font, "Restart", '#fafad2');
	restart_w, restart_h = sprite.size(restart)
	restart_x = SCORES_X + (SCORES_W - restart_w)/2;
	restart_y = theme.get 'scr.h' - restart_h * 2 - restart_h / 2;
	game_restart()
	timer:set(30)
end

function start()
	if info_mode then
		info_toggle()
	end
	game_buttons()
end

function game_buttons()
	local s
	if not info_mode then
		s = sprite.screen()
	else
		s = bg2
	end
	sprite.draw(bg, info_x, info_y, info_w, info_h, s, info_x, info_y);
	sprite.draw(bg, music_x, music_y, music_w, music_h, s, music_x, music_y);
	sprite.draw(bg, restart_x, restart_y, restart_w, restart_h, s, restart_x, restart_y);
	sprite.draw(bg, menu_x, menu_y, menu_w, menu_h, s, menu_x, menu_y);
	
	if info_mode then
		sprite.draw(info_on, s, info_x, info_y)
	else
		sprite.draw(info_off, s, info_x, info_y)
	end

	if not is_music() then
		sprite.draw(music_off, s, music_x, music_y)
	else
		sprite.draw(music_on, s, music_x, music_y)
	end
	sprite.draw(restart, s, restart_x, restart_y)
	sprite.draw(menu_on, s, menu_x, menu_y)
	game_volume()
	show_score(true)
end

function game_volume()
	local s
	if not info_mode then
		s = sprite.screen()
	else
		s = bg2
	end
	sprite.draw(bg, vol_x, vol_y, vol_w, vol_h, s, vol_x, vol_y);
	sprite.draw(vol_empty, s, vol_x, vol_y);
	local v = sound.vol()
	local w = vol_w * v / 127;
	if w > 0 then
		sprite.draw(vol_full, 0, 0, w, vol_h, s, vol_x, vol_y)
	end
end
cur_mul = 0

global { game_over = false }

function game_restart()
	game_over = false
	board_init()
	game_init()
	draw_board()
	draw_pool()
	game_buttons()
	show_hiscores()
	cur_score = -1
	cur_mul = 0
end

function norm_cursor(x, y)
	if x >= BOARD_X and y >= BOARD_Y and x < BOARD_X + BOARD_WIDTH and
		y < BOARD_Y + BOARD_HEIGHT then
			x = (x - BOARD_X) / TILE_WIDTH;
			y = (y - BOARD_Y) / TILE_HEIGHT;
			x = math.floor(x)
			y = math.floor(y)
			x = x * TILE_WIDTH + TILE_WIDTH / 2
			y = y * TILE_HEIGHT + TILE_HEIGHT / 2
			return TILE_WIDTH, TILE_HEIGHT, x + BOARD_X, y + BOARD_Y;
	end
	return 8, 8, x, y
end

game.kbd = function(s, down, key)
	if not down then
		return
	end
	local x,y = mouse_pos()
	if key == 'left' then
		local w,h,x2,y2 = norm_cursor(x, y)
		x = x2 - w
		y = y2
	elseif key == 'right' then
		local w,h,x2,y2 = norm_cursor(x, y)
		x = x2 + w
		y = y2
	elseif key == 'down' then
		local w,h,x2,y2 = norm_cursor(x, y)
		x = x2
		y = y2 + h
	elseif key == 'up' then
		local w,h,x2,y2 = norm_cursor(x, y)
		x = x2
		y = y2 - h
	elseif key == 'space' or key == 'return' then
		game:click(true, 1, x, y)	
	end
	mouse_pos(x, y)
end
game.timer = function(s)
	local x,y = mouse_pos()
	if vol_redraw then
		game_volume()
		vol_redraw = false
	end
	if not info_mode and mouse_on and x >= vol_x and y >= vol_y and x < vol_x + vol_w and
		y < vol_y + vol_h then
		local vol = x - vol_x;
		vol = vol * 127 / vol_w;
		sound.vol(vol)
		game_volume()
	end

	timer_ticks = timer_ticks + 1
	game_move_ball()
	game_process_board()
	game_process_pool()
	show_score()
	game_display_pool()
	local r,v = game_display_board()
	if r == 0 then
		board_logic()
		if board_running() == 0 and not game_over then
			sound.play(gameover_snd)
			game_over = true
--			game_message "Game Over"
			if check_hiscores(board_score()) then
				sound.play(hiscore_snd)
				show_hiscores()
			else
				sound.play(gameover_snd)
			end
		elseif v == 0 and game_over then
			game_message "Game Over"
		end
	end
end

running = true
game.click = function(s, press, mb, x, y)
	if mb ~= 1 then
		board_select(-1, -1)
		return
	end
	mouse_on = press
	if not press then
		return
	end
	if x >= BOARD_X and y >= BOARD_Y and x < BOARD_X + BOARD_WIDTH and
		y < BOARD_Y + BOARD_HEIGHT then
		if board_running() ~= 0 then
			x = (x - BOARD_X) / TILE_WIDTH;
			y = (y - BOARD_Y) / TILE_HEIGHT;
			x = math.floor(x)
			y = math.floor(y)
			board_select(x, y);
--		else
--			game_restart()
		end
	elseif x >= info_x and y >= info_y and x < info_x + info_w and
		y < info_y + info_h then
		return info_toggle()
	elseif x >= music_x and y >= music_y and x < music_x + music_w and
		y < music_y + music_h then
		return music_toggle()
	elseif x >= restart_x and y >= restart_y and x < restart_x + restart_w and
		y < restart_y + restart_h then
		if info_mode then
			info_toggle()
		end
		if board_running() ~= 0 and check_hiscores(board_score()) then
			sound.play(hiscore_snd)
		elseif board_running() ~= 0 then
			sound.play(gameover_snd)
		end
		game_restart()
		return true
	elseif x >= menu_x and y >= menu_y and x < menu_x + menu_w and
		y < menu_y + menu_h then
		mouse_on = false
		vol_redraw = true
		return menu_toggle()
	end
end

global { 
	info_mode = false
}

function music_toggle()
	local s = get_music()
	if not s then
		set_music('snd/satellite.s3m')
	else
		stop_music()
	end
	if info_mode then
		theme.set ('scr.gfx.bg', bg2)
	end
	game_buttons()
	return true
end

function info_toggle()
	info_mode = not info_mode
	if info_mode then
		theme.set ('scr.gfx.mode', 'embedded')
		theme.win.geom (BOARD_X, BOARD_Y, BOARD_WIDTH - 32, BOARD_HEIGHT);
		sprite.copy(bg, bg2)
		show_hiscores()
		game_buttons()
		theme.set ('scr.gfx.bg', bg2)
		return true
	else
		theme.reset 'scr.gfx.mode'
		theme.win.reset ();
		theme.reset 'scr.gfx.bg'
		draw_board()
		draw_pool()
		game_buttons()
		show_hiscores()
	end
end

main = room {
	forcedsc = true;
	nam = '';
	dsc = function(s)
		if not info_mode then
			if theme.get 'scr.gfx.mode' ~= 'direct' then
				pn ""
				p (txtc "To run this game, you must enable own themes setting.")
			end
			return
		end
		p "Try to arrange balls of the same color in vertical,"
		p "horizontal or diagonal lines."
		p "To move a ball click on it to select,"
		p "then click on destination square. Once line has five or more balls"
		p "of same color, that line is removed from the board and you earn score points."
		pn "After each turn three new balls randomly added to the board."
		pn ""
		pn "There are four bonus balls."
		pn ""
		pn (txtnb' '..img(balls[ball_joker][ALPHA_STEPS]).." is a joker that can be used like any color ball. Joker also multiply score by two.")
		pn ""
		pn (txtnb' '..img(balls[ball_bomb][ALPHA_STEPS]).." acts like a joker, but when applied it also removes all balls of the same color from the board.")
		pn ""
		pn (txtnb' '..img(balls[ball_brush][ALPHA_STEPS]).." paints all nearest balls in the same color.")
		pn ""
		pn (txtnb' '..img(balls[ball_boom][ALPHA_STEPS]).." is a bomb. It always does \"boom\"!!!")
		pn ""
		pn "The game is over when the board is filled up."
		pn ""
		pn "<i>CODE: Peter Kosyh <gloomy_pda@mail.ru></i>"
		pn ""
		pn "<i>GRAPHICS: Peter Kosyh and some files from www.openclipart.org</i>"
		pn ""
		pn "<i>SOUNDS: Stealed from some linux games...</i>"
		pn ""
		pn "<i>MUSIC: \"Satellite One\" by Purple Motion.</i>"
		pn ""
		pn "<i>FIRST TESTING & ADVICES: my wife Ola, Sergey Kalichev...</i>"
		pn ""
		pn "<i>SPECIAL THANX: All UNIX world...</i> "
		pn ""
		p (txtc(img(good_luck)))
	end
}

function check_hiscores(score)
	local i
	for i=1, HISCORES_NR do
		if score > prefs.hiscores[i] then
			table.insert(prefs.hiscores, i, score)
			table.remove(prefs.hiscores, HISCORES_NR + 1)
			prefs:store()
			return true
		end
	end
	return false
end
