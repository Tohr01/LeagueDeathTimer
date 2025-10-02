![top_banner](https://github.com/user-attachments/assets/0f04e0f6-58ce-448c-aa2e-9de1b0eac968)

League Death Timer is a little tool I use when i die in the computer game [League of Legends](https://www.leagueoflegends.com/de-de/) in order to know when I am alive again.
The application uses the local [Game client API](https://developer.riotgames.com/docs/lol#game-client-api) to grab the current respawn timer of the current player and displays it in a movable Pop-up at the top (see screenshot below).
You can easiliy access the application in the menu status bar.

## 📸 Screenshot
![screenshot_screen](https://github.com/user-attachments/assets/d7b356d2-2997-4e1a-ad27-0a0a2e1b6ed7)

## 🎯 Requirements
- macOS 13+ (macOS Ventura or higher)
- Xcode (If you want it to compile it yourself)
- League of Legends (Might be obvious)
> [!NOTE]  
> You might need to right-click open the app in order to trust it or run `xattr -d com.apple.quarantine LeagueDeathTimer.app` on the app bundle.

## ⚙️ Custom configuration
The application uses the LCU-Endpoints to determine your language (locale; e.g. en_GB) in order to correctly display your champ as a background.<br><br>
In order to achieve this the program needs to know where your League of Legends App bundle is located. If you moved the Bunde from its default location at `/Applications/League of Legends` you need to override the location in the program plist file located at `~/Library/Preferences/codes.cr.league-death-timer.plist` (Please open the app first in order for it to generate).<br>
Change the key `leagueAppPath` accordingly.

## 🍩 Credits
- Font: [Beaufort for LOL](https://brand.riotgames.com/de-de/league-of-legends/typography/)
- LaunchAtLogin: [LaunchAtLogin-Legacy](https://github.com/sindresorhus/LaunchAtLogin-Legacy)
