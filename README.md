# ButterCatOthello

<p align="center">
  <img src="https://github.com/user-attachments/assets/91e0e43a-af49-40b6-ac2b-f8f8a99c1ed2" width="600" alt="BiBolocアプリのプレビュー">
</p>

<p align="center">
  <strong>「バター猫のパラドックス」から生まれたオセロゲーム</strong>
</p>

<p align="center">
  バター猫オセロはちょっと変わったオセロゲームです。<br>
  通常のコマとは違い、特殊コマが紛れています。
</p>


---

## 特徴

### How to play ?
<img src="https://github.com/user-attachments/assets/563c4357-856a-4f72-8f4c-ec52c3630155" width="600" alt="遊び方">

### 猫の種類
<img src="https://github.com/user-attachments/assets/df4e06ee-94c7-46b4-a17e-3cb49ea97c38" width="600" alt="猫">

---

## 技術スタック
- 言語: Swift
- フレームワーク: UIKit / SwiftUI
- アーキテクチャ: MVC / MVVM
- 開発環境: Xcode

---

## ルール
- バター駒
    - 置くと相手の色になる
    - 自分の色に挟まれた相手の駒は裏返す
    - 裏返しても360度回転して元に戻る
- 猫駒
    - 置くと自分の色になる
    - 自分の色で挟んでも駒を返せない
    - 裏返しても360度回転して元に戻る
- バター猫駒
    - 常に回転し続ける
    - 相手でも自分でもない色扱い
    - バター猫駒を挟んで駒を裏返せない
