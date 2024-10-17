from googleapiclient.discovery import build
import pandas as pd

# YouTube API setup
api_key = 'AIzaSyDyAUJ9rNmhs-haZQaIuQy4k9LnAv_2PzI'
youtube = build('youtube', 'v3', developerKey=api_key)

# Function to get video details including tags
def get_video_details(video_id):
    request = youtube.videos().list(
        part='snippet',
        id=video_id
    )
    response = request.execute()
    # Extracting tags from video details
    video_info = response['items'][0]['snippet']
    tags = video_info.get('tags', [])
    return tags

# Function to get video data
def get_video_data(query, max_results=50):
    request = youtube.search().list(
        q=query,
        part='snippet',
        maxResults=max_results,
        type='video'
    )
    response = request.execute()
    
    # Storing the video information
    video_data = []
    for item in response['items']:
        video_id = item['id']['videoId']
        tags = get_video_details(video_id)  # Get tags for each video

        video = {
            'Title': item['snippet']['title'],
            'Author': item['snippet']['channelTitle'],
            'Description': item['snippet']['description'],
            'Category': query,
            'Date of creation': item['snippet']['publishedAt'],
            'Age Range': 'elementary' if 'kid' in item['snippet']['title'].lower() else 'middle',
            'Length': 'N/A',  # Length is not provided in snippet, needs additional API call (you can modify this to retrieve length),
            'Tags': ', '.join(tags),  # Joining tags into a string
            'URL': f"https://www.youtube.com/watch?v={video_id}",
        }
        video_data.append(video)
    
    return video_data

# Example queries for different academic categories
categories = ['science projects', 'math tutorials', 'history lessons']
all_data = []

# Loop through each category and get the data
for category in categories:
    all_data += get_video_data(category)

# Convert to a pandas DataFrame
df = pd.DataFrame(all_data)

# Save the data to Excel, with each category on a different sheet
with pd.ExcelWriter('YouTube_Tutorials_with_Tags.xlsx') as writer:
    for category in categories:
        category_df = df[df['Category'] == category]
        category_df.to_excel(writer, sheet_name=category, index=False)

















