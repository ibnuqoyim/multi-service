#!/usr/bin/env python3
"""
Simple test script to verify all services are working
"""
import requests
import json

def test_service(name, url):
    """Test a service endpoint"""
    try:
        print(f"\n🔍 Testing {name}: {url}")
        response = requests.get(url, timeout=5)
        print(f"✅ Status: {response.status_code}")
        
        # Try to parse as JSON
        try:
            data = response.json()
            print(f"📄 Response: {json.dumps(data, indent=2)}")
        except:
            print(f"📄 Response: {response.text[:200]}...")
            
    except requests.exceptions.ConnectionError:
        print(f"❌ Connection refused - {name} is not running")
    except requests.exceptions.Timeout:
        print(f"⏰ Timeout - {name} is not responding")
    except Exception as e:
        print(f"❌ Error: {e}")

def main():
    print("🚀 Testing All Services")
    print("=" * 50)
    
    # Test Go service
    test_service("Go Service", "http://localhost:8083/ping")
    
    # Test PHP API (if running)
    test_service("PHP API", "http://localhost:8080/users")
    
    # Test Python service (if running)
    test_service("Python Service", "http://localhost:8082/hello")
    test_service("Python Service Config", "http://localhost:8082/config")
    
    print("\n" + "=" * 50)
    print("✨ Test completed!")

if __name__ == "__main__":
    main()
