-- $Name:Escape The Toilet Pack: A Triple Flush$
-- $Version:1.0$
game.codepage="UTF-8";
instead_version "1.3.1"
require "timer"
require "xact"


global { eng = false; }

------------------------------------------------------------------------------
main = room {
	nam = 'Язык / Language',

	entered = function(s)
		set_music('snd1/noise.ogg');
		return true;
	end;

	obj = { 'trus', 'teng' };
};

trus = obj {
	nam = 'Rus';
	dsc = "^^{Русский}";
	act = function(s)
		eng = false;
		return goto('tgame_menu');
	end;
}

teng = obj {
	nam = 'Eng';
	dsc = "^^{English}";
	act = function(s)
		eng = true;
		return goto('tgame_menu');
	end;
}
------------------------------------------------------------------------------
tgame_menu = room {

	nam = function(s)
		if eng then
			return 'Menu';
		end
		return 'Меню';
	end;

	entered = function(s)
		set_music('snd1/noise.ogg');
		return true;
	end;

	obj = { 'playt1', 'playt2', 'playt3', 'toiletlink' };

}

toiletlink = obj {
	nam = "link";
	dsc = "^^^" .. txtr(txtem("http://toilet.syscall.ru" .. ", 2011"));
}

playt1 = obj {
	nam = 't1';

	dsc = function(s)
		if eng then return '^^{Escape The Toilet: Classic}'; end;
		return '^^{Побег из Туалета: Классический}';
	end;

	act = function(s) return goto('t1start'); end;
}

playt2 = obj {
	nam = 't2';

	dsc = function(s)
		if eng then return '^^{Escape The Toilet 2: Madness Hardened}'; end;
		return '^^{Побег из Туалета 2: Укрепление в безумии}';
	end;

	act = function(s) return goto('t2start'); end;
}

playt3 = obj {
	nam = 't3';

	dsc = function(s)
		if eng then return '^^{Escape The Toilet III: The Ceramic Challenge}'; end;
		return '^^{Побег из Туалета III: Керамическое испытание}';
	end;

	act = function(s) return goto('t3start'); end;
}



------------------------------------------------------------------------------
doencfile("t1.lua.enc");
doencfile("t2.lua.enc");
doencfile("t3.lua.enc");

