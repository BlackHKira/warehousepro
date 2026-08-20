import qrcode
import os

products = [
    ("Coca Cola 355ml", "8934567890001", "A1"),
    ("Pepsi 355ml", "8934567890002", "A1"),
    ("Sting đỏ 330ml", "8934567890003", "A1"),
    ("Number 1 355ml", "8934567890004", "A1"),
    ("7Up 355ml", "8934567890005", "A1"),
    ("Sprite 355ml", "8934567890006", "A1"),
    ("Fanta cam 355ml", "8934567890007", "A1"),
    ("Mirinda Cream Soda 330ml", "8934567890008", "A1"),
    ("Red Bull 250ml", "8934567890015", "B1"),
    ("Monster 355ml", "8934567890016", "B1"),
    ("Sting Vàng 250ml", "8934567890031", "B2"),
    ("Cobra Strike 250ml", "8934567890032", "B2"),
    ("Warrior 250ml", "8934567890033", "B2"),
    ("Aquafina 500ml", "8934567890009", "C1"),
    ("Lavie 500ml", "8934567890013", "C1"),
    ("Dasani 500ml", "8934567890014", "C1"),
    ("Imsong 500ml", "8934567890034", "C1"),
    ("Vihawa 500ml", "8934567890035", "C1"),
    ("Buddha 500ml", "8934567890036", "C1"),
    ("Trà xanh C2 500ml", "8934567890010", "C2"),
    ("Trà ô long T-Plus 500ml", "8934567890049", "C2"),
    ("Trà xanh Không độ 500ml", "8934567890037", "C2"),
    ("Trà sen Tây Hồ 500ml", "8934567890038", "C2"),
    ("Trà nhài Ilsbean 500ml", "8934567890039", "C2"),
]

out_dir = os.path.join(os.path.dirname(__file__), "qr_images")
os.makedirs(out_dir, exist_ok=True)
count = 0

from PIL import Image, ImageDraw, ImageFont

for name, barcode, zone in products:
    qr = qrcode.QRCode(version=1, error_correction=qrcode.constants.ERROR_CORRECT_M, box_size=10, border=2)
    qr.add_data(barcode)
    qr.make(fit=True)
    qr_img = qr.make_image(fill_color="black", back_color="white").convert("RGB")

    w, h = qr_img.size
    canvas = Image.new("RGB", (w, h + 70), "white")
    canvas.paste(qr_img, (0, 0))

    draw = ImageDraw.Draw(canvas)
    try:
        font = ImageFont.truetype("arial.ttf", 16)
        font_small = ImageFont.truetype("arial.ttf", 13)
    except:
        font = ImageFont.load_default()
        font_small = font

    bbox = draw.textbbox((0, 0), name, font=font)
    tw = bbox[2] - bbox[0]
    draw.text(((w - tw) / 2, h + 4), name, fill="black", font=font)

    bbox2 = draw.textbbox((0, 0), barcode, font=font_small)
    tw2 = bbox2[2] - bbox2[0]
    draw.text(((w - tw2) / 2, h + 28), barcode, fill="gray", font=font_small)

    bbox3 = draw.textbbox((0, 0), zone, font=font_small)
    tw3 = bbox3[2] - bbox3[0]
    draw.text(((w - tw3) / 2, h + 48), zone, fill="green", font=font_small)

    safe_name = name.replace(" ", "_").replace("/", "-")
    out_path = os.path.join(out_dir, f"{barcode}_{safe_name}.png")
    canvas.save(out_path)
    count += 1

print(f"Done! {count} QR images saved to: {out_dir}")
