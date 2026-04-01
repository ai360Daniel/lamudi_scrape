from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import sys

def check_versions():
    try:
        options = Options()
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        
        print("Intentando instalar/obtener ChromeDriver...")
        service = Service(ChromeDriverManager().install())
        driver = webdriver.Chrome(service=service, options=options)
        
        print(f"Browser version: {driver.capabilities.get('browserVersion')}")
        print(f"ChromeDriver version: {driver.capabilities.get('chrome', {}).get('chromedriverVersion')}")
        
        driver.quit()
        print("Prueba finalizada exitosamente.")
    except Exception as e:
        print(f"Error detectado: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    check_versions()
