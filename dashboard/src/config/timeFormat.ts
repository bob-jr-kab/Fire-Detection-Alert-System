// Format MongoDB/ISO timestamps to readable formats
export interface FormattedTimestamp {
    time: string;
    date: string;
    fullDateTime: string;
  }
  
  export const formatMongoTimestamp = (isoString: string): FormattedTimestamp => {
    const date = new Date(isoString);
    
    // Format time (09:28 PM)
    const hours = date.getHours();
    const minutes = date.getMinutes().toString().padStart(2, '0');
    const ampm = hours >= 12 ? 'PM' : 'AM';
    const formattedHours = (hours % 12 || 12).toString().padStart(2, '0');
    const formattedTime = `${formattedHours}:${minutes} ${ampm}`;
  
    // Format date (23/03/2025)
    const day = date.getDate().toString().padStart(2, '0');
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const year = date.getFullYear();
    const formattedDate = `${day}/${month}/${year}`;
  
    // Optional: Full date-time string
    const fullDateTime = `${formattedDate} ${formattedTime}`;
  
    return {
      time: formattedTime,
      date: formattedDate,
      fullDateTime
    };
  };
  
  // Optional: Relative time formatter (e.g., "2 hours ago")
  export const formatRelativeTime = (isoString: string): string => {
    const now = new Date();
    const date = new Date(isoString);
    const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);
    
    const intervals = {
      year: 31536000,
      month: 2592000,
      week: 604800,
      day: 86400,
      hour: 3600,
      minute: 60
    };
  
    for (const [unit, secondsInUnit] of Object.entries(intervals)) {
      const interval = Math.floor(seconds / secondsInUnit);
      if (interval >= 1) {
        return `${interval} ${unit}${interval === 1 ? '' : 's'} ago`;
      }
    }
    
    return 'Just now';
  };