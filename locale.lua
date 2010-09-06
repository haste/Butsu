local _NAME, _NS = ...

_NS.L = {
	fish = "Fishy loot",
	empty = "Empty slot",

	uiTitleSize = 'Title font size:',
	uiItemSize = 'Item font size:',
	uiCountSize = 'Count font size:',
	uiIconSize = 'Item icon size:',
	uiFrameScale = 'Frame scale:',

	configDesc = 'Butsu is a small replacement for the default loot frame. It supports showing more than four items, and has a slick look.',
	configNote = 'Note: You can move the frame by holding down <Alt> and clicking on the title.',
}

if ( GetLocale() == "koKR" ) then	-- Korean
_NS.L = {
	fish = "수상한 전리품",
	empty = "빈 공간",

	uiTitleSize = '제목 글꼴 크기:',
	uiItemSize = '아이템 글꼴 크기:',
	uiCountSize = '카운트 글꼴 크기:',
	uiIconSize = '아이템 아이콘 크기:',
	uiFrameScale = '프레임 크기:',

	configDesc = 'Butsu는 기본 전리품 프레임을 작게 바꿔줍니다. 4개 이상의 아이템이 보여지도록 지원하며, 보기 좋게 해줍니다.',
	configNote = '노트: <Alt> 키를 누른 상태에서 제목을 클릭하여 프레임을 이동할 수 있습니다.',
}
end
