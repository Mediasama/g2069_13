import os
import shutil
import subprocess

# Пути (изменяй при необходимости)
SOURCE_DIR = "/storage/emulated/0/g2025_13/g2055"
OUTPUT_DIR = "/storage/emulated/0/g2025_13/g2055_decompiled"
UNLUAC_PATH = os.path.expanduser("~/unluac.jar")

def decompile_lbc(src_path, dest_path):
    """Декомпиляция Lua Bytecode (.lbc) с помощью unluac"""
    try:
        # Меняем расширение выходного файла на .lua
        lua_dest_path = os.path.splitext(dest_path)[0] + ".lua"
        
        # Запуск unluac.jar через Java
        result = subprocess.run(
            ["java", "-jar", UNLUAC_PATH, src_path],
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            with open(lua_dest_path, "w", encoding="utf-8", errors="ignore") as f:
                f.write(result.stdout)
            print(f"[УСПЕХ] Декомпилирован: {src_path} -> {lua_dest_path}")
        else:
            # Если unluac не справился, просто копируем оригинал
            print(f"[ОШИБКА unluac] Не удалось декомпилировать {src_path}. Копирую оригинал.")
            shutil.copy2(src_path, dest_path)
            
    except Exception as e:
        print(f"[КРИТИЧЕСКАЯ ОШИБКА] {src_path}: {e}")
        shutil.copy2(src_path, dest_path)

def process_game_files():
    if not os.path.exists(SOURCE_DIR):
        print(f"Ошибка: Исходная папка {SOURCE_DIR} не найдена!")
        return

    print("Начало копирования структуры и деобфускации...")
    
    for root, dirs, files in os.walk(SOURCE_DIR):
        # Создаем аналогичную структуру папок в целевой директории
        relative_path = os.path.relpath(root, SOURCE_DIR)
        current_dest_dir = os.path.normpath(os.path.join(OUTPUT_DIR, relative_path))
        
        if not os.path.exists(current_dest_dir):
            os.makedirs(current_dest_dir)

        for file in files:
            src_file_path = os.path.join(root, file)
            dest_file_path = os.path.join(current_dest_dir, file)

            # Обработка скомпилированного Lua
            if file.endswith(".lbc"):
                decompile_lbc(src_file_path, dest_file_path)
                
            # Обработка обычного Lua (если там обфускация, пока просто копируем)
            elif file.endswith(".lua"):
                # Здесь можно прописать дополнительную логику очистки текста,
                # если известен конкретный обфускатор.
                shutil.copy2(src_file_path, dest_file_path)
                print(f"[КОПИРОВАНИЕ] Lua скрипт: {file}")
                
            # Все остальные файлы (ассеты: png, mp3, json, ttf и т.д.)
            else:
                shutil.copy2(src_file_path, dest_file_path)

    print(f"\nГотово! Точная копия с декомпилированным кодом создана здесь:\n{OUTPUT_DIR}")

if __name__ == "__main__":
    process_game_files()
