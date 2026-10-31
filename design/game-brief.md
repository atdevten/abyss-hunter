# Game Brief: Abyss Hunter

**One-sentence pitch:** Lặn xuống vực thẳm tối đen, học cách sinh vật biển săn mồi, rồi săn chúng trước khi chúng săn bạn.

## Core loop
- Lặn xuống. Càng sâu càng tối, và đèn vừa giúp bạn nhìn vừa thu hút hoặc xua đuổi sinh vật.
- Chụp ảnh để học về loài (an toàn hơn, không ra tiền), hoặc săn để lấy tiền và phần còn lại của mục bách khoa. Máu loang khi săn sẽ dụ kẻ săn mồi tới.
- Lên mặt nước: bán cá, mở khóa bách khoa. Mỗi mục cho lợi thế khi chơi: hành vi, dấu hiệu cảnh báo, điểm yếu.
- Nâng cấp rồi lặn sâu hơn. Săn quá tay sẽ làm hệ sinh thái phản ứng.

## Player goal & fail state — what "working" looks like
- **Mục tiêu:** Hoàn thành bách khoa 6 loài, với mục cuối nằm ở tầng sâu nhất. Đủ 6 mục là thắng.
- **Một lần lặn thành công:** lên lại thuyền còn sống, mang theo cá hoặc ảnh mới.
- **Thua:** Hết oxy, hoặc hết máu vì bị sinh vật tấn công. Khi đó bạn hồi sinh trên thuyền và mất toàn bộ cá và ảnh đang mang theo.

## MVP — what must exist to be the game
1. Điều khiển bơi lặn, kèm thanh oxy và máu. Càng xuống sâu, oxy tụt càng nhanh
2. Một vùng biển có 3 tầng, tầm nhìn giảm dần (sáng, mờ, tối hẳn). Đèn pin bật tắt được: ở tầng mờ, đèn dụ cá nhỏ lại gần và kẻ săn mồi theo chúng tới; ở tầng tối, ánh đèn trắng làm đa số sinh vật bỏ đi. Tắt đèn thì chỉ thấy ánh phát quang của sinh vật
3. 6 loài dựa trên sinh vật thật, chạy trên 3 kiểu AI: cá mòi (bỏ chạy) và cá nóc (thụ động) ở tầng sáng; cá đèn lồng (bỏ chạy) và cá mập rạn san hô xám (săn mồi) ở tầng mờ; sứa Atolla (thụ động, chớp sáng khi bị tấn công) và mực khổng lồ (săn mồi) ở tầng tối. Máu loang chỉ dụ kẻ săn mồi ở gần, không phải cả bản đồ
4. Súng phóng lao, và máy ảnh có đèn flash. Ở tầng tối, ánh chớp (của flash hay của sứa) dụ kẻ săn mồi tới
5. Bách khoa: ảnh mở một nửa mục (hành vi với con mồi, dấu hiệu cảnh báo với kẻ săn mồi), săn mở nửa còn lại (điểm yếu). Mục mở khi mang lên thuyền; từ đó lợi thế hiện ngay trên sinh vật. Ví dụ: đàn cá đèn lồng co cụm khi có kẻ săn mồi gần; cá mập hếch mõm, cụp vây ngực, cong lưng là đang cảnh báo: lùi lại thì nó bỏ đi, tiến tới thì nó lao vào
6. Thuyền để bán cá và mua 3 nâng cấp: bình oxy (đủ để xuống tầng tối rồi quay lên), lao, đèn đỏ (nhìn ở tầng tối mà sinh vật không thấy). Chết thì hồi sinh trên thuyền và mất cá, ảnh đang mang
7. Chuỗi thức ăn tối giản: con mồi mỗi tầng giảm khi bị săn và hồi dần mỗi lần bạn lên thuyền. Kẻ săn mồi đi theo con mồi: khi tầng của nó cạn mồi, nó ngoi lên tầng nông hơn và hung dữ hơn

## Out of scope — not building this
- Cốt truyện, multiplayer, chế tạo đồ, xây căn cứ, nhiều vùng biển, bản đồ sinh ngẫu nhiên, hệ sinh thái mô phỏng đầy đủ, lưu game (MVP chơi hết trong một lần)

## Build order
1. Bơi lặn, oxy và máu
2. Cá mập rạn san hô xám (có màn cảnh báo và điểm yếu), một con cá nóc làm mồi, súng phóng lao, máu loang. Đây là phần rủi ro nhất: phải chứng minh vui, và chứng minh hiểu biết làm trận đấu khác đi. Chơi cùng một trận khi bật và khi tắt mục bách khoa (công tắc debug); nếu hai trận như nhau thì cái móc của game hỏng.
3. Ba tầng, tầm nhìn và đèn
4. Các loài còn lại, máy ảnh và flash
5. Bách khoa và các lợi thế mở khóa
6. Thuyền: bán cá, nâng cấp, chết rồi hồi sinh
7. Chuỗi thức ăn tối giản. Cắt mục này đầu tiên nếu trễ tiến độ.

---
**Who it's for / what they feel:** Người thích khám phá kèm hành động nhẹ. Cảm giác là tò mò xen hồi hộp, và từ con mồi dần trở thành thợ săn nhờ hiểu biết.

**Art & audio direction:** Pixel art 2D góc nhìn ngang. Càng xuống sâu, màu đỏ mất trước rồi cả cảnh ngả xanh; ở vực sâu, ánh sáng chỉ đến từ đèn của người chơi và ánh phát quang của sinh vật. Nhạc ambient dưới nước, chuyển sang căng thẳng khi kẻ săn mồi xuất hiện.

**Reference game:** Dave the Diver. MVP giữ lại vòng lặp lặn, săn, lên bán rồi nâng cấp, bỏ phần nhà hàng, và thêm điều Dave thiếu: kiến thức thay đổi cách bạn chiến đấu.
