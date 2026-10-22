import 'package:flutter/widgets.dart';

/// Tabler 3.46.0 icons for the mobile icon preview.
///
/// Semantic names preserve existing call sites; artwork matches corevia-talk-app.
/// Native iOS controls share Tabler artwork except Back and Close navigation.
abstract final class CoreviaTalkIcons {
  /// Tabler `filter-2`. Referenced from Dart so release icon pruning retains it.
  static const filter2 = IconData(0x1014b, fontFamily: 'CoreviaTalkTabler');

  static const cornerUpLeft = IconData(0xeb77, fontFamily: 'CoreviaTalkTabler');
  static const droplet = IconData(0xea97, fontFamily: 'CoreviaTalkTabler');

  static const edit = IconData(0xea98, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `text-size`.
  static const aLargeSmall = IconData(0xf2b1, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `activity`.
  static const activity = IconData(0xed23, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `language`.
  static const languages = IconData(0xebbe, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `archive`.
  static const archive = IconData(0xea0b, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `restore`.
  static const archiveRestore = IconData(0xfafd, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `arrow-down`.
  static const arrowDown = IconData(0xea16, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `arrow-left`.
  static const arrowLeft = IconData(0xea19, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `arrows-exchange`.
  static const arrowLeftRight = IconData(0xf1f4, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `arrow-up`.
  static const arrowUp = IconData(0xea25, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `arrows-sort`.
  static const arrowUpDown = IconData(0xeb5a, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `at`.
  static const atSign = IconData(0xea2b, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `bell`.
  static const bell = IconData(0xea35, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `bell-off`.
  static const bellOff = IconData(0xece9, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `bell-ringing`.
  static const bellRing = IconData(0xed07, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `bold`.
  static const bold = IconData(0xeb7b, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `robot`.
  static const bot = IconData(0xf00b, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `brain`.
  static const brain = IconData(0xf59f, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `calendar-time`.
  static const calendarClock = IconData(0xee21, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `camera`.
  static const camera = IconData(0xea54, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `camera-off`.
  static const cameraOff = IconData(0xecee, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `check`.
  static const check = IconData(0xea5e, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `checks`.
  static const checkCheck = IconData(0xebaa, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `chevron-down`.
  static const chevronDown = IconData(0xea5f, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `chevron-left`.
  static const chevronLeft = IconData(0xea60, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `chevron-right`.
  static const chevronRight = IconData(0xea61, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `chevron-up`.
  static const chevronUp = IconData(0xea62, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `circle`.
  static const circle = IconData(0xea6b, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `alert-circle`.
  static const circleAlert = IconData(0xea05, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `circle-check`.
  static const circleCheck = IconData(0xea67, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `circle-dashed`.
  static const circleDashed = IconData(0xed27, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `circle-dot`.
  static const circleDot = IconData(0xefb1, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `circle-x`.
  static const circleX = IconData(0xea6a, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `clock`.
  static const clock = IconData(0xea70, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `clock-hour-3`.
  static const clock3 = IconData(0xf318, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `hourglass`: a channel with a limited lifetime.
  static const clockFading = IconData(0xef93, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `code`.
  static const code = IconData(0xea77, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `coffee`.
  static const coffee = IconData(0xef0e, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `compass`.
  static const compass = IconData(0xea79, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `copy`.
  static const copy = IconData(0xea7a, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `download`.
  static const download = IconData(0xea96, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `dots`.
  static const ellipsis = IconData(0xea95, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `dots-vertical`.
  static const ellipsisVertical = IconData(0xea94, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `external-link`.
  static const externalLink = IconData(0xea99, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `file`.
  static const file = IconData(0xeaa4, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `file-pencil`.
  static const filePen = IconData(0xf039, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `file-text`.
  static const fileText = IconData(0xeaa2, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `fingerprint`.
  static const fingerprint = IconData(0xebd1, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `flag`.
  static const flag = IconData(0xeaa6, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `folder`.
  static const folder = IconData(0xeaad, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `folder-code`.
  static const folderGit2 = IconData(0xf90f, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `folder-symlink`.
  static const folderInput = IconData(0xf91b, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `folder-minus`.
  static const folderMinus = IconData(0xeaaa, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `folder-plus`.
  static const folderPlus = IconData(0xeaab, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `carousel-horizontal`.
  static const galleryThumbnails = IconData(0xf659, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `git-pull-request`.
  static const gitPullRequest = IconData(0xeab6, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `hash`.
  static const hash = IconData(0xeabc, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `headphones-off`.
  static const headphoneOff = IconData(0xed1d, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `headphones`.
  static const headphones = IconData(0xeabd, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `heart`.
  static const heart = IconData(0xeabe, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `home`.
  static const house300 = IconData(0xeac1, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `home`.
  static const house500 = IconData(0xeac1, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `photo`.
  static const image = IconData(0xeb0a, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `photo-off`.
  static const imageOff = IconData(0xecf6, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `library-photo`.
  static const images = IconData(0xfd4a, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `inbox`.
  static const inbox300 = IconData(0xeac4, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `inbox`.
  static const inbox500 = IconData(0xeac4, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `italic`.
  static const italic = IconData(0xeb93, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `key`.
  static const key = IconData(0xeac7, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `layout-grid`.
  static const layoutGrid = IconData(0xedba, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `leaf`.
  static const leaf = IconData(0xed4f, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `bulb`.
  static const lightbulb = IconData(0xea51, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `link`.
  static const link = IconData(0xeade, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `link`.
  static const link2 = IconData(0xeade, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `loader-2`.
  static const loaderCircle = IconData(0xf226, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `lock`.
  static const lock = IconData(0xeae2, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `login`.
  static const logIn = IconData(0xeba7, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `logout`.
  static const logOut = IconData(0xeba8, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `mail`.
  static const mail = IconData(0xeae5, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `mail-check`.
  static const mailCheck = IconData(0xf939, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `mail-opened`.
  static const mailOpen = IconData(0xeae4, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `message-circle`.
  static const messageCircle = IconData(0xeaed, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `message`.
  static const messageSquare = IconData(0xeaef, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `message-reply`.
  static const messageSquareReply = IconData(0xfd4d, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `message-2`.
  static const messageSquareText = IconData(0xeaec, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `messages`.
  static const messagesSquare = IconData(0xeb6c, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `microphone`.
  static const mic = IconData(0xeaf0, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `microphone-off`.
  static const micOff = IconData(0xed16, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `moon`.
  static const moon = IconData(0xeaf8, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `palette`.
  static const palette = IconData(0xeb01, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `player-pause`.
  static const pause = IconData(0xed45, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `pencil`.
  static const pencil = IconData(0xeb04, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `phone-off`.
  static const phoneOff = IconData(0xecf5, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `plane`.
  static const plane = IconData(0xeb6f, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `player-play`.
  static const play = IconData(0xed46, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `plus`.
  static const plus = IconData(0xeb0b, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `radio`.
  static const radio = IconData(0xef2d, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `rotate`.
  static const refreshCcw = IconData(0xeb16, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `rotate-clockwise`.
  static const refreshCw = IconData(0xeb15, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `face-id`.
  static const scanFace = IconData(0xea9b, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `scan`.
  static const scanLine = IconData(0xebc8, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `search`.
  static const search = IconData(0xeb1c, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `search`.
  static const search300 = IconData(0xeb1c, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `search`.
  static const search500 = IconData(0xeb1c, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `search-off`.
  static const searchX = IconData(0xf19c, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `settings`.
  static const settings = IconData(0xeb20, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `share`.
  static const share = IconData(0xeb21, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `share`.
  static const share2 = IconData(0xeb21, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `shield`.
  static const shield = IconData(0xeb24, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `shield-exclamation`.
  static const shieldAlert = IconData(0xf9c6, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `shield-check`.
  static const shieldCheck = IconData(0xeb22, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `mood-smile`.
  static const smile = IconData(0xeaf7, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `mood-plus`.
  static const smilePlus = IconData(0xf7b9, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `sparkles`.
  static const sparkles = IconData(0xf6d7, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `square`.
  static const square = IconData(0xeb2c, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `code-dots`.
  static const squareCode = IconData(0xf61a, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `star`.
  static const star = IconData(0xeb2e, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `star-off`.
  static const starOff = IconData(0xed62, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `strikethrough`.
  static const strikethrough = IconData(0xeb9e, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `sun`.
  static const sun = IconData(0xeb30, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `sun-moon`.
  static const sunMoon = IconData(0xf4a3, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `camera-rotate`.
  static const switchCamera = IconData(0xee22, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `trash`.
  static const trash2 = IconData(0xeb41, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `alert-triangle`.
  static const triangleAlert = IconData(0xea06, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `user`.
  static const user = IconData(0xeb4d, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `user-minus`.
  static const userMinus = IconData(0xeb4a, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `user-plus`.
  static const userPlus = IconData(0xeb4b, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `user`.
  static const userRound = IconData(0xeb4d, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `users`.
  static const users = IconData(0xebf2, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `video`.
  static const video = IconData(0xed22, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `video-off`.
  static const videoOff = IconData(0xed20, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `ball-volleyball`.
  static const volleyball = IconData(0xec2b, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `volume`.
  static const volume2 = IconData(0xeb51, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `volume-off`.
  static const volumeX = IconData(0xf1c3, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `wifi-off`.
  static const wifiOff = IconData(0xecfa, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `tool`.
  static const wrench = IconData(0xeb40, fontFamily: 'CoreviaTalkTabler');

  /// Tabler `x`.
  static const x = IconData(0xeb55, fontFamily: 'CoreviaTalkTabler');
}
