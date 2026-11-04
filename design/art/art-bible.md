# Art Bible: Abyss Hunter

> **Status**: Approved
> **Owned By**: art-director
> **Last Updated**: 2026-11-03
> **Art Director Sign-Off (AD-ART-BIBLE)**: SKIPPED 2026-11-03 — solo mode

`/art-bible` writes these nine sections in this order and replaces each
section's `[To be designed]` line as that section is approved. A section still
holding its placeholder is incomplete; a later run fills only those.

## 1. Visual Identity Statement

**Quy tắc một dòng:** *Bóng tối là mặc định; mọi pixel sáng đều phải là thông tin về một sinh vật hoặc một lựa chọn của người chơi.*

Hình ảnh phục vụ việc **đọc hành vi** con mồi và kẻ săn mồi. Thị giác là công cụ săn, không phải trang trí. Nguồn gốc: pitch ("học cách chúng săn mồi, rồi săn chúng trước") và cảm giác tò mò xen hồi hộp. (Brief không có trụ cột; các nguyên tắc neo vào pitch và dòng "what they feel".)

### Nguyên tắc hỗ trợ

1. **Đọc được trước, đẹp sau (silhouette-first).**
   - Mỗi loài nhận ra được bằng bóng một màu ở kích thước thật (cá mòi ~20 px đến mực khổng lồ ~130 px).
   - Tư thế cảnh báo của cá mập (mõm hếch, vây ngực hạ, lưng cong), điểm yếu, đàn cá co cụm và nháy xanh của sứa Atolla phải đọc được trong < 0,5 s.
   - *Phép thử:* khi chi tiết hoặc thẩm mỹ xung đột với tín hiệu hành vi, chọn tín hiệu.
   - *Neo:* kiến thức chỉ làm trận đấu khác đi (hook của game) nếu người chơi **thấy** được dấu hiệu.

2. **Ánh sáng là thông tin và là lựa chọn.**
   - Chỉ có 3 nguồn sáng: đèn người chơi (trắng hoặc đỏ), phát quang của sinh vật, ánh mặt trời giảm dần. Mỗi nguồn có màu và ý nghĩa cố định.
   - Đèn trắng: hiện hình nhưng dọa hoặc thu hút; đèn đỏ: nhìn được mà không bị thấy.
   - *Phép thử:* khi không chắc có thêm vùng sáng không, chọn tối, trừ khi vùng đó báo một sinh vật hoặc hệ quả của đèn.
   - *Neo:* căng thẳng đến từ bóng tối che giấu kẻ săn mồi và từ cái giá của đèn.

3. **Độ sâu là bảng màu đọc được.**
   - Đỏ mất trước, cảnh ngả xanh qua 3 tầng (sáng, mờ, tối). Mỗi tầng một gam màu, độ bão hòa giảm dần; chỉ ánh phát quang và máu giữ độ bão hòa cao ở tầng sâu.
   - *Phép thử:* chọn màu mà ở độ sâu đó thật sự còn tồn tại; đỏ ở tầng tối chỉ dành cho máu và đèn đỏ.
   - *Neo:* người chơi cảm được mình xuống sâu và hiểm họa tăng, trước cả khi nhìn đồng hồ.

### Look của game KHÔNG phải

- Đại dương rực rỡ, dễ thương, bão hòa đều khắp tầng sâu.
- Kinh dị jump-scare hay gore: máu là tín hiệu hút kẻ săn mồi, không phải cảnh tượng.
- Pixel art "thực tế hóa" nhiều chi tiết: ưu tiên hình khối rõ, ít chi tiết (như Dave the Diver), một cỡ pixel nhất quán, không trộn độ phân giải.
- "Tối vì tối": nếu bóng tối không che giấu hay báo hiệu gì thì là sai.

### Ràng buộc kỹ thuật cho các mục sau

Compatibility renderer, cũng chạy trên Web (WebGL2). `PointLight2D` + `CanvasModulate` theo tầng. Tối đa 16 nguồn sáng trên một vật thể: hiệu ứng phát quang nên dùng sprite phát sáng (additive) thay vì thêm nguồn sáng.

**Còn mở, chốt ở Mục 8:** 1 pixel art = 1 pixel thật, hay phóng 2× trên khung 1152×648.

## 2. Mood & Atmosphere

Mỗi trạng thái có một "chữ ký" riêng: nhiệt độ màu, độ tương phản và một vật mang không khí.

1. **Mặt nước / thuyền**: an toàn, nhẹ nhõm, chuẩn bị. Ấm (~5500 K), tương phản thấp, ambient `#D1F0FF`, nắng vàng nhạt. *Thoáng, ấm, phẳng, sạch.* Năng lượng thấp. Vật mang: mặt trời và chân trời (nơi duy nhất có bầu trời).
2. **Lặn tầng sáng (0–50 m)**: tò mò, thoải mái. Mát (~7000 K), tương phản thấp–trung, water `#409ED9`, tia nắng xiên. *Trong, rộng, nhộn nhịp, an toàn có điều kiện.* Năng lượng trung bình–thấp. Vật mang: tia nắng và đàn cá mòi lấp lánh.
3. **Tầng mờ, tắt đèn**: dè chừng, thu mình. Lạnh (~9000 K), tương phản trung, ambient `#386BAD`, chi tiết nền mất dần. *Lạnh, đục, im, rình rập.* Năng lượng trung bình–thấp. Vật mang: chấm cyan của cá đèn lồng.
4. **Tầng mờ, bật đèn**: kiểm soát nhưng "bị nhìn thấy". Nón sáng trắng ấm (~4500 K) trên nền xanh lạnh, tương phản cao theo vùng. *Chọn lọc, lộ, tập trung.* Năng lượng trung bình. Vật mang: vòng sáng rìa mềm; sinh vật trong vòng hiện màu thật.
5. **Tầng tối, tắt đèn**: nín thở, cô lập. Ambient `#050812`, chỉ chấm phát quang rời rạc, phần sáng < 5% khung hình. *Câm, vô tận, lơ lửng, chờ đợi.* Năng lượng rất thấp. Vật mang: chấm cyan/xanh trôi trong mực; người lặn gần như vô hình.
6. **Tầng tối, đèn trắng**: dũng cảm, phơi bày. Trắng trung tính (~6500 K), cực gắt, rìa cứng hơn ở tầng mờ; ngoài nón là đen thuần. *Gắt, lộ liễu, hút mắt, bất ổn.* Năng lượng cao. Vật mang: nón sáng như đèn pha, bóng đổ dài ra ngoài vùng sáng.
7. **Tầng tối, đèn đỏ**: kín đáo, thợ săn. Đơn sắc đỏ `#E8203A`, cường độ thấp hơn đèn trắng; ánh phát quang cyan giữ nguyên màu. *Rình, hẹp, ngột, săn.* Năng lượng thấp–trung. Vật mang: vòng đỏ nhỏ mờ, đối lập trực tiếp với trạng thái 6.
8. **Căng thẳng: cá mập cảnh báo / lao tới**: sợ có kiểm soát. Không thêm nguồn sáng; viền tối (vignette) co dần ở rìa, tương phản tăng, bão hòa nền giảm ~15%; khi lao tới co thêm. *Nén, nghẹt, gấp, im trước bão.* Năng lượng tăng dần rồi lên đỉnh. Vật mang: vignette co theo khoảng cách và bóng cá mập hếch mõm. Không rung hình, không gore.
9. **Flash / chụp ảnh**: khoảnh khắc tách khỏi thời gian. Khung trắng gắt 2–3 frame, rồi giữ khung trắng, nền hạ ~30% độ sáng. *Đóng băng, sắc, ngắn, tách.* Năng lượng: một xung ngắn. Vật mang: khung chữ nhật trắng và flash.
10. **Chết / hồi sinh**: mất mát nhẹ, không trừng phạt. Mất màu về xanh–xám, đám máu cuối là thứ duy nhất còn màu, mờ dần về đen; hồi sinh sáng dần ở mặt nước ấm. *Chìm, lặng, xám, rồi nhẹ.* Năng lượng giảm dần. Vật mang: bong bóng khí cuối cùng đi lên.
11. **Cửa hàng / bách khoa / bộ sưu tập**: tĩnh, học hành. UI phẳng, nền `#0E1E36` (không nhận tint của tầng), panel hơi ấm (~5000 K), không glow, không tia nắng. *Yên, gọn, ấm, như sổ ghi chép.* Năng lượng rất thấp. Vật mang: bóng đen cho loài chưa biết, lên màu khi mở khóa.
12. **Thắng (6/6)**: thấu hiểu, kính nể. Ấm hơn trạng thái 1; 6 sinh vật phát sáng nhỏ xếp hàng trên nền `#050812`, không pháo hoa. *Trang trọng, trong, tĩnh, "đã hiểu".* Năng lượng thấp, ấm dần lên. Vật mang: cả 6 loài cùng lộ đủ màu thật trong một khung.

**Khác biệt chính giữa các trạng thái:** ấm hay lạnh (1, 2, 11, 12 so với 3–7), vùng sáng cục bộ (4, 6, 7), vignette co (8), khung trắng ngắn (9), mất màu (10).

*Ghi chú hiện trạng:* tia nắng xiên, vignette khi cá mập cảnh báo, hiệu ứng mất màu khi chết và màn hình thắng riêng chưa có trong game; đây là hướng dẫn, mỗi thứ cần một story riêng.

## 3. Shape Language

### Silhouette (nguyên tắc 1)

Tô mỗi loài một màu đặc ở kích thước thật: vẫn phải phân biệt được chỉ bằng **một** đặc điểm. Không chi tiết bên trong thân nào gánh việc nhận diện.

| Loài | Kích thước (px) | Đặc điểm nhận diện |
|---|---|---|
| Cá mòi | 22×8 | Thân thon đối xứng, đuôi chẻ; nhận ra theo đàn |
| Cá nóc | 30×30 | Gần tròn hoàn hảo, vây nhỏ lòi ra; hình tròn duy nhất ở tầng sáng |
| Cá đèn lồng | 20×8 | Thân dẹt tối và chấm phát quang ở bụng. Bóng gần giống cá mòi: nhận diện chủ yếu bằng ánh sáng và tầng (Mục 5 không đòi bóng riêng) |
| Cá mập rạn san hô xám | 96×30 | Thoi dài, vây lưng tam giác, đuôi lưỡi liềm; hình nhiều góc nhọn nhất |
| Sứa Atolla | 40×28 | Vòm tròn và tua thả thẳng đứng; hình duy nhất có "đuôi" dọc |
| Mực khổng lồ | 130×36 | Thân (mantle) thon dài, cụm tua rối xòe ở đầu, mắt phát sáng; lớn nhất |

### Kẻ săn mồi và con mồi (nguyên tắc 1)

- **Kẻ săn mồi:** góc nhọn, thân dài, tam giác; hình dáng báo trước hướng lao tới.
- **Con mồi:** bầu tròn, ngắn, không báo trước gì; đọc ra là "dễ chạy".
- **Hai ngoại lệ có chủ ý:** sứa Atolla (tròn nhưng là mồi nhử vì nháy sáng dụ kẻ săn mồi) và mực (kẻ săn mồi nhưng thân mềm, tua rối thay vì góc nhọn, để khác cá mập và trông "lạ").

### 3 tư thế cá mập (đọc được trong < 0,5 s, nguyên tắc 1)

1. **Tuần tra:** thân ngang thẳng, vây ngực dang ngang; hình thoi dài và thấp.
2. **Cảnh báo:** mõm hếch ~25–30°, vây ngực rũ xuống, lưng cong cung; bóng vồng lên, cao hơn, chiều dài hiệu dụng ngắn lại. **Khung bao phải khác tư thế tuần tra**, không chỉ khác chi tiết.
3. **Lao tới:** thân thẳng, mõm chĩa vào người chơi, vây ép sát; hẹp, dạng mũi tên.

### Môi trường (nguyên tắc 3)

- **Tầng sáng:** đường cong lớn, đá bo tròn, san hô chùm.
- **Tầng mờ:** đá vát góc, vách dốc, ít chi tiết.
- **Tầng tối:** chỉ còn hình khối lớn đơn giản, một viền.
- Nền luôn tương phản thấp hơn sinh vật và không có góc nhọn tách rời có thể nhầm với vây cá mập.

### UI (nguyên tắc 2)

- **Vòng tròn** = vùng ảnh hưởng (đèn, vòng bỏ chạy, vòng điểm yếu); phân biệt bằng nét liền, nét đứt hay nét dày.
- **Mũi tên** = hướng.
- **Chữ nhật góc vuông** = thứ do người chơi tạo ra (khung ảnh, bảng).
- Bảng bo góc nhẹ 2 px.
- **Góc nhọn chỉ dành cho nguy hiểm.**

### Hình chính và hình phụ

- **Chính (hero):** cá mập, mục tiêu hiện tại, vòng điểm yếu; có viền sáng 1 px khi nằm trong vùng đèn.
- **Phụ:** con mồi nền và môi trường; không có viền.
- Tối đa 1–2 hình chính trên mỗi khung hình.

## 4. Color System

### Bảng màu chính (7)

| Tên | Mã | Ý nghĩa trong thế giới |
|---|---|---|
| Abyss Ink | `#050812` | Mặc định, vùng chưa biết |
| Sunwater Blue | `#409ED9` | Nước tầng sáng, an toàn |
| Bio Cyan | `#4DE8FF` | Phát quang, có sự sống |
| Lamp White | `#FFF6E0` | Đèn: nhìn thấy và bị thấy (trắng ấm, tách khỏi cyan) |
| Lamp Red | `#E8203A` | Đèn đỏ: nhìn mà không bị thấy |
| Blood | `#A8001C` | Máu: hút kẻ săn mồi |
| Signal Yellow | `#FFE14D` | Điểm yếu, mục tiêu |

### Theo tầng (giữ giá trị trong `src/world/layers_config.tres`; kênh đỏ giảm dần)

- **Sáng:** ambient `#D1F0FF`, water `#409ED9`, bão hòa cao.
- **Mờ:** ambient `#386BAD`, water `#1A528C`, đỏ gần mất.
- **Tối:** ambient `#050812`, water `#081433`; chỉ ánh phát quang, máu và đèn giữ được độ bão hòa.
- Thân sứa Atolla (`#8C141F`) và mực khổng lồ (`#8C2633`) đỏ thẫm, gần vô hình ở tầng tối: **ngụy trang có chủ ý**, chỉ ánh phát quang hiện ra.

### Ý nghĩa màu

- **Trắng đèn** = nhìn thấy và bị thấy. **Đỏ đèn** = nhìn mà không bị thấy.
- **Cyan / xanh** = sinh vật sống. Sứa Atolla `#4080FF` tách khỏi cyan của cá đèn lồng; mắt mực `#D9F2BF`.
- **Đỏ máu** = nguy hiểm; chỉ ở đám máu và thanh máu (HP).
- **Vàng** = điểm yếu.
- **Cam** `#FF9A1F` = đang chờ, chưa mở. **Xanh lá** `#4FD18B` = đã mở, hoàn thành. Cam và xanh lá **chỉ có trong UI**, không có trong thế giới.

### Bảng màu UI

Panel `#0E1E36`, chữ `#E6F0FA`, accent Signal Yellow. Cùng họ màu với thế giới, nhưng UI nằm trên lớp riêng và **không nhận `CanvasModulate`**, nên đọc được ở mọi tầng.

### An toàn cho người mù màu

| Cặp dễ hỏng | Dự phòng |
|---|---|
| Thanh máu đỏ / thanh oxy xanh | Biểu tượng tim / bình khí, nhãn số; máu thấp thì nháy kèm âm thanh |
| Vàng điểm yếu / cam đang chờ | Điểm yếu = vòng nét đứt xoay có chấm tâm; đang chờ = biểu tượng đồng hồ cát; không cùng màn hình |
| Xanh lá đã mở / cam đang chờ | Dấu tick so với đồng hồ cát / ổ khóa; ô chưa mở là bóng đen |
| Đèn đỏ / máu | Đèn = vòng sáng rìa mềm gắn với người chơi; máu = đám đục có hạt, kèm âm thanh riêng |
| Cyan cá đèn lồng / xanh sứa Atolla | Cá đèn lồng = chấm nhỏ cố định ở bụng; sứa = quầng lớn nhấp nháy, kèm âm thanh |
| Vàng điểm yếu / mắt mực, đèn trắng | Điểm yếu luôn là vòng; mắt mực là chấm đặc |

**Nguyên tắc:** không thông tin nào chỉ dựa vào một màu. Đề xuất tùy chọn "gợi ý tương phản cao" (Mục 7).

*Ghi chú hiện trạng:* dấu tick, biểu tượng tim, bình khí và đồng hồ cát chưa có trong game; HUD hiện chỉ có thanh màu và chữ.

## 5. Character Design Direction

### Người lặn (nhân vật người chơi)

- **Hình mẫu:** thợ lặn tự do thực dụng, không phải siêu anh hùng: đồ lặn tối, mặt nạ, chân vịt, bình khí trên lưng.
- **Kích thước:** ~28×12 px khi bơi ngang, ~12×26 px khi đứng trên thuyền. To hơn cá mòi, nhỏ hơn cá mập rõ rệt: người chơi luôn *cảm* mình là con mồi trước.
- **Màu đồ lặn:** xám xanh trung tính, bão hòa thấp. Cấm 7 màu ngữ nghĩa trên thân (không đỏ, vàng, cyan, trắng đèn). Ở tầng tối khi tắt đèn, người lặn gần như vô hình (Mục 2, trạng thái 5): đây là chủ ý.
- **Ba đặc điểm phải đọc được ở mọi frame:**
  1. **Đèn gắn đầu** (mũ hoặc mặt nạ): nón sáng xuất phát từ đầu, theo hướng mặt; thấu kính đổi màu trắng ấm / đỏ theo chế độ. Đây là pixel sáng duy nhất của nhân vật.
  2. **Súng lao:** vạch thẳng 1–2 px chĩa ra trước tay, dài ≥ 1/2 thân; góc nhọn duy nhất của người lặn, đọc ra "thợ săn".
  3. **Máy ảnh:** khối vuông 3×3 px thay súng lao trong tay. Không bao giờ cầm cả hai cùng lúc: công cụ đang dùng đọc được bằng bóng.
- **Nâng cấp hiện trên sprite:** bình oxy đơn → bình đôi (lưng dày thêm 2 px, thấy được trên thuyền và ở tầng sáng); đèn đỏ thêm vòng thấu kính đỏ 1 px; mũi lao dài hoặc rộng hơn. Nâng cấp không thêm pixel sáng nào khác.

### Phân biệt ở cái nhìn đầu tiên (nối Mục 3)

- **Kẻ săn mồi:** góc nhọn, khung bao dài, tối hơn nền; viền sáng 1 px khi vào vùng đèn (hình chính).
- **Con mồi:** tròn hoặc ngắn, không viền, luôn đi theo cụm hoặc trôi lững lờ.
- **Mồi nhử (Atolla):** tròn, tua dọc, thân đỏ thẫm gần vô hình; nhận ra bằng **nhịp sáng**, không bằng hình (quầng `#4080FF` nhấp nháy, kèm âm thanh).
- **Mực:** kẻ săn mồi không góc nhọn; nhận ra bằng kích thước (lớn nhất) và 2 chấm mắt `#D9F2BF` cố định.

### Tư thế và biểu cảm

- Động vật thật, **không mặt hoạt hình**: không lông mày, không miệng cười, mắt là chấm 1–2 px.
- "Biểu cảm" = tư thế toàn thân: cường điệu tư thế, không cường điệu khuôn mặt. Dáng hơi cứng như phim tài liệu, nhưng khung bao đổi rõ.
- **Nhịp hoạt hình then chốt:**
  - Cá mập: tuần tra loop 6 fr; chuyển sang cảnh báo 3 fr, giữ cảnh báo loop 2 fr (lắc nhẹ); lao tới 2 fr lấy đà + 2 fr lao.
  - Atolla nháy: quầng additive 4 fr (bừng, đỉnh, đỉnh, tắt) lặp theo nhịp; không thêm `PointLight2D`.
  - Đàn co cụm: do AI siết khoảng cách, không phải animation từng con; mỗi con quẫy đuôi nhanh hơn (2 fr, tốc độ ×2).
  - Người lặn: bơi 6 fr, lơ lửng 4 fr, bắn 3 fr, chụp 2 fr.
- **Số frame tối thiểu:** cá nhỏ 2 fr bơi; cá vừa (nóc, Atolla) 4 fr; cá lớn (cá mập, mực) 6 fr bơi. Mỗi trạng thái hành vi có ≥ 1 frame chuyển tiếp riêng, không cắt cứng.

### Ngân sách chi tiết (LOD 2D)

- **~20 px** (cá mòi, cá đèn lồng, người lặn): bóng + **một** tín hiệu (ánh bụng 1 px / chấm phát quang / đèn); tối đa 2 sắc độ.
- **~30–40 px** (cá nóc, Atolla): 3 sắc độ, mắt 1 px, gai/tua là phần của bóng.
- **~96–130 px** (cá mập, mực): 4 sắc độ, mắt 2 px, khe mang 1 px; vùng điểm yếu phải có chỗ cho vòng vàng mà không chồng chi tiết.
- Chi tiết nào không sống được khi tô đặc một màu ở kích thước thật thì không được gánh thông tin.

### Đọc được trên nền (ràng buộc với Mục 6)

- Sinh vật và người lặn luôn tương phản sắc độ ≥ 3:1 với nền cục bộ (đá, san hô, nước).
- Không loài nào cùng sắc độ với props của tầng nó sống.

### Kích thước cách điệu

Kích thước sinh vật là **kích thước gameplay, cách điệu, không đúng tỷ lệ thật** (ở 16 px = 1 m, cá mập 96 px ≈ 6 m, trong khi cá mập rạn san hô xám thật ~2 m). Sprite người lặn 28×12 px so với hitbox hiện tại (hình tròn ~20 px) được quyết khi làm sprite.

## 6. Environment Design Language

### "Kiến trúc" của biển khơi (theo vùng biển thật, độ sâu đã nén cho game)

- **Tầng sáng (0–50 m, ~ epipelagic gần bờ):** rạn san hô và đá bo tròn ở rìa và đáy khung, tảo bẹ (kelp) đung đưa, dải cát nhạt.
- **Tầng mờ (~ mesopelagic):** sườn lục địa dốc, đá vát góc, vài bọt biển / san hô nước lạnh thưa. **Hết kelp** (không đủ ánh sáng): đây là mốc độ sâu.
- **Tầng tối (~ bathypelagic):** gần như chỉ có nước và hạt trôi; đáy biển (nếu có) là một khối silhouette lớn, một viền, không chi tiết.
- Môi trường là **khung**, không phải đấu trường. Đáy và rìa chủ yếu để trang trí; có va chạm hay không là quyết định gameplay, không thuộc mục này.

### Triết lý texture (pixel art)

- Màu phẳng, đổ bóng theo khối lớn; nguồn sáng giả định từ trên xuống (mặt trời) ở tầng sáng và mờ.
- Bóng **ngả xanh** (hue-shift về xanh), không chỉ tối đi; đỏ biến mất theo tầng (Mục 4).
- **Số sắc độ mỗi chất liệu:** tầng sáng 3–4; tầng mờ 2–3; tầng tối 1–2.
- **Dithering:** chỉ cho nền nước lớn (chuyển gradient giữa các tầng) và tia nắng, ordered 2×2. **Cấm trên sinh vật và người lặn.**
- Không viền đen cho môi trường; viền sáng 1 px chỉ dành cho hình chính (Mục 3).

### Mật độ props theo tầng

- **Sáng (dày):** props phủ ~30–40% khung hình, tập trung ở đáy và rìa; chừa vùng nước giữa trống cho đàn cá mòi. Rạn đông đúc cho cảm giác an toàn, sống động.
- **Mờ (thưa):** ~10–15%; khoảng trống lớn tạo cảm giác rình rập và chừa chỗ cho bóng cá mập đọc được.
- **Tối (gần trống):** < 5%, khớp quy tắc "phần sáng < 5%"; không có gì để nấp hay định hướng, chỉ có đèn và phát quang.

### Parallax và hạt

- **4 lớp:** nền xa (gradient nước + bóng rạn hoặc vách mờ, hệ số ~0,2); nền giữa (silhouette đá / kelp, ~0,5); lớp chơi (1,0); lớp hạt tiền cảnh (~1,2, chỉ có hạt, **không props che sinh vật**).
- **Hạt:** tia nắng xiên chỉ ở tầng sáng (mờ dần về tầng mờ); bọt khí từ người lặn theo nhịp thở; tuyết biển (marine snow) ở tầng mờ và tối: hạt xám trắng 1 px, alpha thấp.
- **Tuyết biển không bao giờ là cyan và không phát sáng**, để không nhầm với cá đèn lồng hay Atolla.
- **Luật cứng:** nền và props tương phản sắc độ tối đa ~1,5:1 với màu nước của tầng; không lớp nền nào tương phản hơn sinh vật; không cạnh nhọn tách rời giống vây (Mục 3).

### Kể chuyện bằng môi trường (không chữ)

- **Độ sâu tự đọc được qua cảnh:** tia nắng thưa dần; kelp dừng ở ranh giới sáng–mờ; đá đổi từ tròn sang vát góc; tuyết biển dày dần; ở tầng tối, ngoài vùng đèn là đen thuần.
- **Mốc chuyển tầng:** một dải "thermocline" mờ (nước gợn nhẹ, đổi tint) báo sắp vào tầng mới, trước cả đồng hồ độ sâu.
- **Tùy chọn (set dressing, mỗi thứ cần story riêng):** xác cá voi (whale fall) trên đáy tầng tối làm mốc định hướng; vài vỏ ốc / bộ xương trên đá tầng mờ gợi có kẻ săn mồi. Chỉ là silhouette tương phản thấp, không gore.
- **Săn quá tay** chỉ phản ánh bằng việc thấy ít cá hơn (thuộc gameplay); môi trường không tự đổi màu.

### Thuyền và mặt nước

- Mặt nước là đường gợn sáng 2–3 px; phía trên là nơi duy nhất có bầu trời và mặt trời ấm (Mục 2, trạng thái 1).
- **Thuyền:** thuyền lặn nhỏ, rộng ~96–128 px; thân trắng ngà xỉn hoặc gỗ. **Không dùng `#FFF6E0`, đỏ, vàng hay cam** (đã dành cho đèn, máu, mục tiêu, UI). Đây là vật ấm nhất thế giới.
- **Từ dưới nước:** đáy thuyền là bóng tối trên mặt nước sáng: dấu hiệu "đường về" khi ngước lên từ tầng sáng.
- **Tùy chọn (story riêng):** dây lặn thả từ thuyền xuống hết tầng sáng, vừa đúng thật vừa giúp định hướng.

## 7. UI/HUD Visual Direction

### Diegetic và screen-space

- **Screen-space** (CanvasLayer riêng, không nhận `CanvasModulate`): oxy, máu, tiền, cargo, số loài trong bách khoa. Ở tầng tối người lặn gần như vô hình (Mục 2, trạng thái 5), nên chỉ số sống còn không được phụ thuộc vào thế giới.
- **Oxy hiển thị lai:** thanh trên HUD là nguồn chính; bọt khí của người lặn (Mục 6) thưa dần khi oxy cạn là tín hiệu phụ, không bao giờ thay thanh.
- **Gắn vào thế giới nhưng là UI:** vòng kiến thức trên sinh vật, mũi tên hướng, khung ảnh ở con trỏ. Bám theo vị trí trong thế giới nhưng vẽ trên lớp overlay, **không bị tint, không nhận ánh sáng**.
- **HUD là biểu tượng + số, không viết thành câu.** Dòng prey/tầng là readout debug: ẩn ở bản chơi, chỉ bật bằng cờ hoặc phím riêng.
- **HUD có backing panel mờ** (alpha ~60%) để không đọc trực tiếp trên nền nước hay vùng đèn. Cố định ở góc, độ sáng thấp hơn nón đèn, không glow, không viền sáng 1 px (dành cho hình chính). Thanh có **độ rộng cố định**, không giãn theo chữ. Vùng chơi giữa màn hình không có UI tĩnh.

### Typography

- **Font:** một họ pixel font, tính cách "sổ ghi chép / dive computer": gọn, kỹ thuật, không fantasy. Regular cho chữ thường, Bold cho tiêu đề và số quan trọng; chữ số tabular để bộ đếm không nhảy. Nếu Việt hóa: font phải có đủ dấu chồng ("ệ", "ở"), line-height ~1,5×.
- **Thang cỡ chữ (ở 1152×648):** tiêu đề màn hình 28, chữ thường 20, **tối thiểu 18 px** cho mọi thông tin gameplay. Có tùy chọn **UI scale 100 / 125 / 150%**; chữ không được nhỏ hơn mức tối thiểu sau khi canvas Web co lại. *(Quyết định: chọn theo ux-designer thay vì 16 px trên lưới 8 px của art-director, vì trên Web canvas co theo trình duyệt.)*
- **Viền chữ:** chữ HUD `#E6F0FA` có viền 1 px `#050812`; chữ trong panel `#0E1E36` không cần viền. Signal Yellow chỉ cho mục đang chọn hoặc mục tiêu, không làm màu chữ thường.
- **Tương phản:** mọi chữ và thanh UI ≥ 4,5:1 so với nền ngay sau nó. Màu thanh UI được sáng hơn màu thế giới cùng nghĩa: thanh máu UI ~`#E0303F` (Blood `#A8001C` chỉ đạt ~2:1 trên nền tối).

### Iconography

- **Lưới:** biểu tượng HUD 16×16, biểu tượng panel 32×32 (phóng 2× nguyên). Hình đặc một màu, viền ngoài 1 px `#050812`, tối đa 2 sắc độ, không dithering.
- **Theo Mục 3:** tim, bình khí, đồng hồ cát (đang chờ), dấu tick (đã mở), ổ khóa. Tròn = vùng, mũi tên = hướng, khung vuông = thứ người chơi tạo, góc nhọn chỉ cho nguy hiểm. Mỗi biểu tượng nhận ra được khi tô đặc một màu.
- Mỗi thanh có **biểu tượng kèm số**; trạng thái bách khoa và bộ sưu tập dùng biểu tượng (tick / đồng hồ cát / khóa), không chỉ màu.
- **Gợi ý phím:** mỗi panel có dòng gợi ý ở chân panel; trên thuyền hiện gợi ý ngữ cảnh "B: cửa hàng". Phím hiển thị dạng keycap chữ nhật, không màu ngữ nghĩa, đi qua một bảng tra để sau này thay glyph (tay cầm).

### UI animation

- **Mở panel (E / C / B):** 120–150 ms, trượt 8 px kèm fade, chuyển động theo bước pixel, không bounce, không overshoot; đóng ~100 ms.
- **Đang chờ → đã mở:** bóng đen lên màu thật trong 4 frame, đồng hồ cát đổi thành tick, ô nháy xanh lá `#4FD18B` một lần. Không hạt, không glow (glow dành cho phát quang).
- **Oxy thấp:** dưới 25% thanh và biểu tượng bình khí nhấp nháy 2 Hz; dưới 10% lên 3 Hz kèm âm thanh. **Không vượt 3 lần/giây.** Không dùng cam (cam = đang chờ), không dùng vignette (dành cho cá mập, Mục 2 trạng thái 8).

### Vòng kiến thức trên sinh vật (lớp overlay)

- **Ngôn ngữ chung:** nét 1 px, giữ độ dày khi zoom, không tô đặc, không additive/glow, alpha 80–90% (vòng phụ ≤ 60%), bám lưới pixel, **không bị tint hay chiếu sáng**: không thể nhầm với phát quang hay với viền sáng của hình chính.
- **Từng loại:**
  - Điểm yếu: vòng nét đứt vàng xoay + chấm tâm.
  - Vòng bỏ chạy: nét chấm `#E6F0FA` 40%.
  - Vòng "rời đi" của cá mập: xanh lá liền + mũi tên hướng ra ngoài (ngoại lệ có chủ ý: xanh lá xuất hiện trong thế giới, nhưng thuộc lớp overlay UI).
  - **Vòng "sắp lao tới": vòng răng cưa / chevron góc nhọn, màu `#E6F0FA` hoặc vàng, không dùng đỏ** (đỏ dành cho máu và đèn đỏ, Mục 4; góc nhọn = nguy hiểm, Mục 3). *(Quyết định: thay vòng đỏ hiện tại.)*
  - Hướng bơi: mũi tên `#E6F0FA`.
- Chỉ hiện cho loài đã mở trong bách khoa; **tối đa 1–2 sinh vật hiện đủ vòng cùng lúc** (luật hình chính, Mục 3); các con khác chỉ hiện vòng ưu tiên cao nhất, mờ dần theo khoảng cách.

### Khung ảnh

Nét trắng mảnh 1 px khi ngắm, chỉ đậm lúc chụp (Mục 2, trạng thái 9); ẩn con trỏ hệ thống khi khung đang hiện.

### Ràng buộc chuyển cho UX / gameplay (không phải quyết định art)

- Panel không được che vùng chơi khi game đang chạy: hoặc **tạm dừng** khi mở, hoặc chỉ cho mở trên thuyền, hoặc panel bán trong / thu gọn với oxy và máu luôn nằm trên panel.
- **Tối đa một panel modal:** mở panel mới thì đóng panel cũ (hiện C và E chồng nhau).
- Thứ tự ưu tiên và lọc các vòng kiến thức; tách cờ debug; danh sách phím, remap, hỗ trợ tay cầm; cấp accessibility (`/ux-design accessibility`).

*Ghi chú hiện trạng:* game hiện dùng font mặc định, HUD bằng chữ, vòng "sắp lao tới" màu đỏ, các vòng nhận `CanvasModulate`, dòng prey debug luôn hiện. Mỗi điểm cần một story để khớp với mục này.

## 8. Asset Standards

### Tỷ lệ pixel (chốt câu hỏi mở ở Mục 1)

- **1 pixel art = 1 pixel thế giới tại viewport 1152×648.** Kích thước ở Mục 3 và 5 (cá mòi 22×8, người lặn 28×12, mực 130×36) là kích thước vẽ thật.
- **Lý do:** giữ nguyên hitbox, tầm nhìn và tỷ lệ 16 px = 1 m; vẽ ở nửa độ phân giải thì cá 20 px chỉ còn ~10 px art, mất ngân sách 2 sắc độ.
- **Scale màn hình:** `stretch/mode = canvas_items`, `aspect = keep`, scale mượt (không integer). **Trade-off chấp nhận:** ở 1080p (×1,67) pixel to nhỏ không đều.
- **Phương án bị loại:** base 640×360 + integer scale (×2 ở 720p, ×3 ở 1080p) cho pixel đều tuyệt đối, nhưng thu nhỏ tầm nhìn, cá 20 px còn ~10 px, và phải dựng lại UI bách khoa, bộ sưu tập, cửa hàng. *(Quyết định: chọn 1:1 theo art-director; technical-artist ghi nhận 1152×648 không scale nguyên được lên 720p/1080p.)*

### Định dạng và đặt tên

- **Source:** `.aseprite` (mỗi frame một cel, layer `glow` riêng), đặt cạnh file `.png` (Godot bỏ qua đuôi này); cân nhắc Git LFS cho file nguồn.
- **Export:** `.png` RGBA 8-bit, sRGB, không nhúng ICC profile.
- **Sprite sheet:** mỗi trạng thái của một loài là một dải ngang, ô đều nhau; không xuất từng frame lẻ.
- **Tên (snake_case):** `[category]_[name]_[state]_f[N].png`, ví dụ `creature_grey_reef_shark_display_f3.png`, `char_diver_swim_f6.png`, `env_light_rock_round_large.png`, `vfx_atolla_flash_glow_f4.png`, `ui_icon_heart.png`.
  - Category: `creature_`, `char_`, `env_`, `vfx_`, `ui_`. Slug loài: `sardine`, `pufferfish`, `lanternfish`, `grey_reef_shark`, `atolla_jellyfish`, `giant_squid`.
  - `f[N]` = số frame (khớp Mục 5); ảnh tĩnh không có hậu tố.

### Kích thước ô (cell) theo lớp

| Lớp | Ô (px) |
|---|---|
| Nhỏ: cá mòi, cá đèn lồng | 24×16 |
| Vừa: cá nóc, người lặn (chứa cả tư thế ngang 28×12 và đứng 12×26) | 32×32 |
| Vừa: sứa Atolla | 48×32 |
| Lớn: cá mập (khung bao tư thế cảnh báo cao hơn tuần tra) | 112×48 |
| Lớn: mực khổng lồ | 144×48 |

- Mọi trạng thái của một loài dùng chung ô và chung pivot (tâm thân), để pivot không nhảy khi đổi tư thế.
- Chừa ≥ 2 px lề mỗi cạnh cho viền sáng 1 px. Không bắt buộc lũy thừa 2.

### Bảng màu

- `assets/art/palettes/abyss_hunter.gpl` + `.hex`: index 0–6 khóa đúng 7 màu ngữ nghĩa ở Mục 4; chỉ đổi khi sửa art bible.
- Mỗi tầng một file: `palette_layer_light.gpl`, `palette_layer_dim.gpl`, `palette_layer_dark.gpl`. Màu UI (cam, xanh lá) ở `palette_ui.gpl`, không có trong palette thế giới.
- Review từ chối mọi sprite thế giới hoặc người lặn dùng màu ngữ nghĩa sai chỗ (Mục 4, 5, 6).

### Export và import (Godot 4.7, Compatibility, Web)

- Không anti-aliasing, không resample khi xuất, không dithering trên sinh vật và người lặn.
- **Project settings phải đổi:** `default_texture_filter` sang **Nearest** (hiện là Linear); bật `snap_2d_transforms_to_pixel` (hiện tắt); đặt stretch như trên (hiện `disabled`).
- **Import:** mipmap tắt; nén **Lossless** (lên GPU là RGBA8); không dùng VRAM Compressed (gây vỡ khối trên pixel art).
- **Ngoại lệ:** texture gradient của ánh sáng (`GradientTexture2D` của đèn) giữ lọc Linear qua override từng node, để viền sáng không thành bậc thang khi bị phóng to.

### Giới hạn Web (WebGL2)

- Sprite sheet / atlas ≤ **2048×2048** (WebGL2 chỉ bảo đảm `MAX_TEXTURE_SIZE` ≥ 2048); không cần power-of-two. Mỗi loài một sheet (6 trạng thái × 6 frame × 130 px vừa trong 1024×1024).
- **Draw call (≤ 500):** một atlas mỗi loài, material dùng chung, glow additive vẽ liền nhau (cùng z_index / nhóm) để không phá batch. Vài chục sinh vật + 4 lớp parallax vẫn dư nhiều; rủi ro chính là ánh sáng, không phải draw call.
- **Ánh sáng 2D:** tối đa 16 light trên mỗi canvas item; light vượt quá bị **bỏ qua mà không báo lỗi**, và mỗi light trúng item làm tăng chi phí fragment.

### Glow / phát quang

- Vẽ trên layer `glow` riêng, xuất file `_glow` cùng ô và số frame với sprite thân; màu đặc, chỉ Bio Cyan, `#4080FF` hoặc `#D9F2BF`, tối đa 2 mức alpha.
- Engine hiển thị bằng `CanvasItemMaterial` với `blend_mode = Add`, `light_mode = Unshaded`, **không thêm `PointLight2D`**. `CanvasModulate` vẫn nhân màu lên item cùng canvas layer kể cả unshaded: nếu glow cần sáng ở tầng sâu thì đặt trên CanvasLayer riêng hoặc bù độ sáng; phải chụp kiểm tra trên Web.

### Hạt và âm thanh

- **Hạt:** `CPUParticles2D` cho bọt khí, máu, tuyết biển (chạy mọi backend, không khựng lần emit đầu trên WebGL2, tất định). Bản Web single-threaded nên hạt tính trên main thread: cần trần số hạt mỗi emitter và tổng.
- **Âm thanh Web** (playback Sample, bus effect hạn chế): SFX ngắn WAV 16-bit (có thể 22,05 kHz); nhạc nền và ambience Ogg Vorbis stream.

### Vị trí trong repo

`assets/art/{creatures/<loài>, characters/diver, environment/<tầng>, vfx, ui, palettes}/`.

### Còn mở / lệch với hiện trạng

- **Phát quang đang dùng `PointLight2D`** (`src/world/glow_light.gd`), trái với quy định glow = sprite additive. Khi đàn cá đông, đèn người lặn, flash và glow có thể vượt 16 light trên một item. Cần một story code để chuyển sang sprite.
- **Memory ceiling cho Web** (đang TBC trong technical-preferences) và **ngân sách hạt** chưa đặt. Ước tính: sprite sinh vật 2–6 MB; mỗi lớp parallax rộng gấp 3 màn hình ~9 MB, 4 lớp ~12–36 MB (parallax là khoản tốn bộ nhớ chính).
- Đổi stretch mode sang `canvas_items` cần chụp lại UI hiện có để kiểm tra.

*Nguồn:* phần art theo art-director; giới hạn engine theo technical-artist (đã đọc project bằng `godot --headless` 4.7.2 cho các giá trị hiện tại; giới hạn 16 light, kích thước texture WebGL2, batching và hành vi của particles là kiến thức chưa kiểm chứng trong engine reference).

## 9. Reference Direction

Mỗi nguồn chỉ gánh **một** phần việc; không nguồn nào được lấy "toàn bộ aesthetic".

1. **Dave the Diver** (Mintrocket, 2023): *sprite và vòng lặp*.
   - **Lấy:** sprite sinh vật ít chi tiết, nhận ra bằng bóng; nhịp đổi rõ giữa thuyền ấm và lúc lặn (Mục 2, trạng thái 1 và 2).
   - **Tránh:** màu bão hòa đều ở mọi độ sâu; nhân vật có mặt hoạt hình và gag (trái Mục 5); HUD dày chữ. *[Chưa kiểm chứng: nền của Dave có thể là 3D phối sprite pixel. Ta giữ một cỡ pixel, không pha 3D (Mục 1, 8).]*
2. **Blue Planet II, tập "The Deep"** (BBC, 2017) + **video ROV của MBARI**: *ánh sáng môi trường ở tầng tối*.
   - **Lấy:** đèn ROV là một nón sáng duy nhất, ngoài nón là đen thuần; tuyết biển chỉ hiện khi lọt vào nón; phát quang là chấm rời trên nền đen thật (Mục 2, trạng thái 5 và 6; Mục 6).
   - **Tránh:** gradient và tán xạ thể tích kiểu ảnh thật: ta dịch sang 1–2 sắc độ, glow tối đa 2 mức alpha (Mục 8). Đèn ROV trắng xanh; Lamp White của ta là trắng ấm `#FFF6E0`.
3. **Edith Widder: camera Medusa + mồi E-Jelly** (cảnh mực khổng lồ quay tại chỗ năm 2012): *tín hiệu sinh vật và đèn đỏ*.
   - **Lấy:** E-Jelly là vòng 16 LED xanh nháy theo kiểu "báo động chống trộm" của Atolla và đã dụ được mực khổng lồ; Medusa quay bằng ánh đỏ mà sinh vật không thấy. Căn cứ thật cho nhịp nháy `#4080FF` (Mục 5) và cho đèn đỏ "nhìn mà không bị thấy" (Mục 4).
   - **Tránh:** khung hình lấy nét kém, nhiễu camera; ánh đỏ đơn sắc phủ cả màn hình. Đèn đỏ của ta là vòng nhỏ, cyan và xanh giữ nguyên màu (Mục 2, trạng thái 7). *[Chưa kiểm chứng: cảnh quay thứ hai ở vịnh Mexico năm 2019.]*
4. **Johnson & Nelson 1973**, "Agonistic Display in the Gray Reef Shark", *Copeia* 1973(1): 76–84 (DOI 10.2307/1442360; dùng tên loài cũ *C. menisorrah*): *tư thế cảnh báo của cá mập*.
   - **Lấy:** các dấu hiệu cảnh báo (mõm hếch, vây ngực hạ, lưng cong, thân uốn sang bên) và cường độ tăng khi người lặn áp sát hoặc chặn đường thoát. Nguồn cho 3 tư thế ở Mục 3 và vòng "sắp lao tới" (Mục 7).
   - **Tránh:** giải phẫu và tỷ lệ thật (kích thước cách điệu 96 px, Mục 5); không lấy ảnh mẫu có chi tiết thân, chỉ lấy khung bao. *[Chưa kiểm chứng: mô tả dấu hiệu lấy từ nguồn thứ cấp; chưa đọc bản đầy đủ, chưa biết bài có hình vẽ tư thế không.]*
5. **Inside** (Playdead, 2016): *bố cục và sắc độ*.
   - **Lấy:** nền nén về gần một sắc độ, nhân vật nhỏ và tối; mối nguy đọc ra bằng bóng trong khoảng trống; một màu nhấn dành riêng cho một nghĩa. Áp cho mật độ props ở tầng mờ và tối (Mục 6) và luật tối đa 1–2 hình chính (Mục 3).
   - **Tránh:** dựng hình 3D, depth-of-field, sương xám lục, giọng kinh dị (trái Mục 1). Ta đổi màu bóng sang xanh và giữ tương phản ≥ 3:1 cho sinh vật.

**Đã cân nhắc, không chọn:** Limbo (đơn sắc có hạt phim, trùng hướng với Inside, mất màu ngữ nghĩa); Iconoclasts (pixel đẹp nhưng không dùng bóng tối làm thông tin); Ernst Haeckel cho màn bách khoa (tính trang trí trái với chữ "gọn, kỹ thuật" của Mục 7).

**Nguồn tra cứu:**
- [Johnson & Nelson 1973, trang tra cứu](https://sharks.linnaeus.naturalis.nl/linnaeus_ng/app/views/literature2/reference.php?id=36923)
- [elasmo-research: agonistic displays](https://www.elasmo-research.org/education/topics/b_agonism.htm)
- [NOAA: camera Medusa](https://oceanexplorer.noaa.gov/explorations/15biolum/background/medusa/medusa.html)
- [Live Science: Deep Sea Tech Unveils Giant Squid](https://www.livescience.com/27872-deep-sea-tech-unveils-giant-squid.html)
