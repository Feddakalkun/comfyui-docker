import requests
import os
import argparse
import time
from urllib.parse import urlparse

def download_image(url, folder, filename):
    try:
        response = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
        if response.status_code == 200:
            filepath = os.path.join(folder, filename)
            with open(filepath, 'wb') as f:
                f.write(response.content)
            print(f"Downloaded: {filename}")
            return True
    except Exception as e:
        print(f"Failed to download {url}: {e}")
    return False

def scrape_reddit(subreddit, limit, sort="top", time_filter="all"):
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'}
    
    output_dir = os.path.join("assets", "training_data", subreddit)
    os.makedirs(output_dir, exist_ok=True)
    
    count = 0
    after = None
    
    print(f"Fetching from r/{subreddit} ({sort}/{time_filter})... Target: {limit} images")
    
    while count < limit:
        # Reddit JSON API URL with pagination
        url = f"https://www.reddit.com/r/{subreddit}/{sort}.json?t={time_filter}&limit=100"
        if after:
            url += f"&after={after}"
            
        try:
            response = requests.get(url, headers=headers)
            if response.status_code != 200:
                print(f"Error: Reddit returned status code {response.status_code}")
                break

            data = response.json()
            posts = data['data']['children']
            after = data['data']['after']
            
            if not posts:
                print("No more posts found.")
                break
            
            for post in posts:
                if count >= limit:
                    break
                    
                post_data = post['data']
                image_url = post_data.get('url_overridden_by_dest', '')
                
                # Check if it's an image
                if image_url.endswith(('.jpg', '.jpeg', '.png', '.webp')):
                    # Clean filename
                    filename = os.path.basename(urlparse(image_url).path)
                    # Avoid duplicates
                    if os.path.exists(os.path.join(output_dir, filename)):
                        continue
                        
                    if download_image(image_url, output_dir, filename):
                        count += 1
                        print(f"Progress: {count}/{limit}")
            
            if not after:
                break
                
            time.sleep(1) # Be nice to API
            
        except Exception as e:
            print(f"An error occurred: {e}")
            break
                    
    print(f"Successfully downloaded {count} images to {output_dir}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Download images from a subreddit")
    parser.add_argument("subreddit", help="Name of the subreddit (e.g., midjourney)")
    parser.add_argument("--limit", type=int, default=25, help="Number of posts to check")
    parser.add_argument("--sort", default="top", choices=["hot", "new", "top"], help="Sort order")
    parser.add_argument("--time", default="all", choices=["hour", "day", "week", "month", "year", "all"], help="Time filter for 'top'")
    
    args = parser.parse_args()
    
    # Sanitize subreddit input (remove r/ or /r/ prefix if present)
    clean_subreddit = args.subreddit
    if clean_subreddit.startswith("r/") or clean_subreddit.startswith("R/"):
        clean_subreddit = clean_subreddit[2:]
    elif clean_subreddit.startswith("/r/"):
        clean_subreddit = clean_subreddit[3:]
        
    scrape_reddit(clean_subreddit, args.limit, args.sort, args.time)
