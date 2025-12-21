#!/usr/bin/env python3
"""
Script dịch thuật sử dụng Google Translate
Dịch từ tệp assets/translations/en.json sang các ngôn ngữ khác
"""

import json
import asyncio 
import sys
from pathlib import Path
from googletrans import Translator
import time
from typing import Dict, Any

# Cấu hình các ngôn ngữ đích
TARGET_LANGUAGES = {
    'vi': 'Vietnamese',
    'de': 'German', 
    'es': 'Spanish',
    'fr': 'French',
    'ja': 'Japanese',
    'ko': 'Korean',
    'zh_CN': 'Chinese (Simplified)',
    'zh_TW': 'Chinese (Traditional)'
}

class TranslationManager:
    def __init__(self):
        self.translator = Translator()
        self.base_path = Path(__file__).parent.parent / "assets" / "translations"
        self.source_file = self.base_path / "en.json"
        
    def load_source_file(self) -> Dict[str, Any]:
        """Đọc tệp en.json gốc"""
        try:
            with open(self.source_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except FileNotFoundError:
            print(f"❌ Không tìm thấy tệp: {self.source_file}")
            sys.exit(1)
        except json.JSONDecodeError as e:
            print(f"❌ Lỗi đọc JSON: {e}")
            sys.exit(1)
    
    async def translate_text(self, text: str, dest_lang: str) -> str:
        """Dịch một đoạn văn bản"""
        if not text or text.strip() == "":
            return text
            
        try:
            # Thêm delay để tránh rate limiting
            time.sleep(0.1)
            result = await self.translator.translate(text, src='en', dest=dest_lang)
            return result.text
        except Exception as e:
            print(f"⚠️  Lỗi dịch '{text[:50]}...': {e}")
            return text  # Trả về text gốc nếu lỗi
    
    async def translate_value(self, value: Any, dest_lang: str) -> Any:
        """Dịch giá trị (có thể là string, dict, hoặc list)"""
        if isinstance(value, str):
            return await self.translate_text(value, dest_lang)
        elif isinstance(value, dict):
            return {k: await self.translate_value(v, dest_lang) for k, v in value.items()}
        elif isinstance(value, list):
            return [await self.translate_value(item, dest_lang) for item in value]
        else:
            return value
    
    async def translate_file(self, source_data: Dict[str, Any], dest_lang: str) -> Dict[str, Any]:
        """Dịch toàn bộ tệp"""
        print(f"🌐 Bắt đầu dịch sang {TARGET_LANGUAGES[dest_lang]} ({dest_lang})...")
        
        translated_data = {}
        total_keys = self._count_keys(source_data)
        processed_keys = 0
        
        async def translate_recursive(data: Dict[str, Any], result: Dict[str, Any]):
            nonlocal processed_keys
            for key, value in data.items():
                processed_keys += 1
                print(f"📝 Đang dịch ({processed_keys}/{total_keys}): {key}")
                result[key] = await self.translate_value(value, dest_lang)
        
        await translate_recursive(source_data, translated_data)
        print(f"✅ Hoàn thành dịch {total_keys} keys")
        return translated_data
    
    async def _count_keys(self, data: Dict[str, Any]) -> int:
        """Đếm tổng số keys cần dịch"""
        count = 0
        for value in data.values():
            if isinstance(value, dict):
                count += await self._count_keys(value)
            elif isinstance(value, list):
                count += len(value)
            else:
                count += 1
        return count
    
    async def save_translation(self, data: Dict[str, Any], dest_lang: str):
        """Lưu bản dịch vào tệp"""
        output_file = self.base_path / f"{dest_lang}.json"
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"💾 Đã lưu: {output_file}")
        except Exception as e:
            print(f"❌ Lỗi lưu file {output_file}: {e}")
    
    async def translate_all(self):
        """Dịch sang tất cả các ngôn ngữ"""
        print("🚀 Bắt đầu quá trình dịch thuật...")
        print(f"📂 Tệp nguồn: {self.source_file}")
        
        # Đọc tệp gốc
        source_data = self.load_source_file()
        print(f"📖 Đã đọc {len(source_data)} keys từ tệp gốc")
        
        # Dịch sang từng ngôn ngữ
        for lang_code, lang_name in TARGET_LANGUAGES.items():
            print(f"\n{'='*50}")
            try:
                translated_data = await self.translate_file(source_data, lang_code)
                await self.save_translation(translated_data, lang_code)
                print(f"🎉 Hoàn thành dịch sang {lang_name}")
            except Exception as e:
                print(f"❌ Lỗi dịch sang {lang_name}: {e}")
            
            # Delay giữa các ngôn ngữ
            await asyncio.sleep(1)
        
        print(f"\n{'='*50}")
        print("🎊 Hoàn thành tất cả bản dịch!")
    
    async def translate_specific_language(self, lang_code: str):
        """Dịch sang một ngôn ngữ cụ thể"""
        if lang_code not in TARGET_LANGUAGES:
            print(f"❌ Ngôn ngữ không được hỗ trợ: {lang_code}")
            print(f"📋 Các ngôn ngữ có sẵn: {', '.join(TARGET_LANGUAGES.keys())}")
            return
        
        print(f"🎯 Dịch sang {TARGET_LANGUAGES[lang_code]} ({lang_code})...")
        
        source_data = await self.load_source_file()
        translated_data = await self.translate_file(source_data, lang_code)
        await self.save_translation(translated_data, lang_code)
        
        print(f"✅ Hoàn thành dịch sang {TARGET_LANGUAGES[lang_code]}!")

async def main():
    """Hàm chính"""
    print("🔤 Translation Script sử dụng Google Translate")
    print("=" * 50)
    
    manager = TranslationManager()
    
    # Kiểm tra tham số dòng lệnh
    if len(sys.argv) > 1:
        lang_code = sys.argv[1]
        if lang_code == "--list" or lang_code == "-l":
            print("📋 Các ngôn ngữ được hỗ trợ:")
            for code, name in TARGET_LANGUAGES.items():
                print(f"  • {code}: {name}")
            return
        else:
            await manager.translate_specific_language(lang_code)
    else:
        # Dịch tất cả các ngôn ngữ
        await manager.translate_all()

if __name__ == "__main__":
    asyncio.run(main())