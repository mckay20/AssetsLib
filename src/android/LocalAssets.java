package com.localassets;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;

import org.apache.cordova.PluginResult;
import org.apache.cordova.CordovaInterface;
import android.provider.MediaStore;
import android.content.Context;
import android.database.Cursor;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.provider.Settings;
import android.widget.Toast;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.view.View;
import android.view.Menu;
import android.view.MenuItem;
import java.util.ArrayList;
import android.media.ExifInterface;
import java.io.*;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;



public class LocalAssets extends CordovaPlugin {

    public static final String TAG = "Local Assets";
    public String out = "fail";

    public static final String CAMERA_IMAGE_BUCKET_NAME =
            Environment.getExternalStorageDirectory().toString()
            + "/DCIM/Camera";
    public static final String CAMERA_IMAGE_BUCKET_ID =
            getBucketId(CAMERA_IMAGE_BUCKET_NAME);

    public static String getBucketId(String path) {
        return String.valueOf(path.toLowerCase().hashCode());
    }

    public Context context;



    /**
    * Constructor.
    */
    public LocalAssets() {}

    /**
    * Sets the context of the Command. This can then be used to do things like
    * get file paths associated with the Activity.
    *
    * @param cordova The context of the main Activity.
    * @param webView The CordovaWebView Cordova is running in.
    */

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        context = cordova.getActivity().getApplicationContext();
        Log.v(TAG,"Init LocalAssets");
    }

    @Override
    public boolean execute(final String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        JSONObject jo = new JSONObject();
        jo.put("firstName", "John");
        jo.put("lastName", "Doe");

        JSONArray ja = new JSONArray();
        ja.put(jo);

        if(action.equals("getAllPhotos")){
            PluginResult result = new PluginResult(PluginResult.Status.OK, getAllPhotos());
                            result.setKeepCallback(false);
                            callbackContext.sendPluginResult(result);
        }
        else if(action.equals("getPhotoMetadata")){
             getPhotoMetadata();
        }
        else if(action.equals("getThumbnails")){
              PluginResult result = new PluginResult(PluginResult.Status.OK, getThumbnails());
                                         result.setKeepCallback(false);
                                         callbackContext.sendPluginResult(result);
        }
        else if(action.equals("getPhoto")){
            //final int duration = Toast.LENGTH_SHORT;
            // Shows a toast
            //Log.v(TAG,"LocalAssets received:"+ "getPhotoMetadata");

            //out = args.getJSONArray(0).getString(0);

            //cordova.getActivity().runOnUiThread(new Runnable() {
            //    public void run() {
             //       Toast toast = Toast.makeText(cordova.getActivity().getApplicationContext(), out, duration);
             //       toast.show();
             //   }
            //});


             PluginResult result = new PluginResult(PluginResult.Status.OK, getPhoto(args.getJSONArray(0).getString(0), args.getInt(1)));
                                                      result.setKeepCallback(false);
                                                      callbackContext.sendPluginResult(result);
        }
        return true;

    }
    public JSONArray getAllPhotos() {
        final String[] projection = { MediaStore.Images.Media.DATA };
        final String selection = MediaStore.Images.Media.BUCKET_ID + " = ?";
        final String[] selectionArgs = { CAMERA_IMAGE_BUCKET_ID };
        final Cursor cursor = context.getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                null);
        //ArrayList<String> result = new ArrayList<String>(cursor.getCount());
        JSONArray result = new JSONArray();
        if (cursor.moveToFirst()) {
            final int dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            do {
                try{
                    final String data = cursor.getString(dataColumn);
                    ExifInterface exif = new ExifInterface(data);
                    final String date = exif.getAttribute(ExifInterface.TAG_DATETIME);
                    JSONObject obj = new JSONObject();
                    obj.put("date", date);
                    obj.put("id", data);
                    obj.put("lat", getDegree(exif, 1));
                    obj.put("lng", getDegree(exif, 0));
                    obj.put("orientation", exif.getAttribute(ExifInterface.TAG_ORIENTATION));
                    //obj.put("lat", exif.getAttribute(ExifInterface.TAG_GPS_LATITUDE));
                    //obj.put("lng", exif.getAttribute(ExifInterface.TAG_GPS_LONGITUDE));
                    result.put(obj);
                }catch( Exception e){

                }
            } while (cursor.moveToNext());
        }
        cursor.close();
        return result;
    }

    public boolean getPhotoMetadata(){
     final int duration = Toast.LENGTH_SHORT;
        // Shows a toast
        Log.v(TAG,"LocalAssets received:"+ "getPhotoMetadata");


        cordova.getActivity().runOnUiThread(new Runnable() {
            public void run() {
                Toast toast = Toast.makeText(cordova.getActivity().getApplicationContext(), "getPhotoMetadata", duration);
                toast.show();
            }
        });
        return true;
    }
    public JSONArray getThumbnails(){

        final String[] projection = { MediaStore.Images.Media.DATA };
        final String selection = MediaStore.Images.Media.BUCKET_ID + " = ?";
        final String[] selectionArgs = { CAMERA_IMAGE_BUCKET_ID };
        final Cursor cursor = context.getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                selectionArgs,
                null);
        //ArrayList<String> result = new ArrayList<String>(cursor.getCount());
        JSONArray result = new JSONArray();
        if (cursor.moveToFirst()) {
            final int dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            do {
                try{
                    final String data = cursor.getString(dataColumn);
                    ExifInterface exif = new ExifInterface(data);
                    JSONObject obj = new JSONObject();
                    obj.put("data",  base64Thumb(data));
                    obj.put("id",  data);
                    obj.put("date",  exif.getAttribute(ExifInterface.TAG_DATETIME));
                    obj.put("orientation", exif.getAttribute(ExifInterface.TAG_ORIENTATION));

                    result.put(obj);
                }catch( Exception e){

                }
            } while (cursor.moveToNext());
        }
        cursor.close();
        return result;
    }


   public JSONArray getPhoto(String fileName, int size){
        File dir=Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM);
        Bitmap b = BitmapFactory.decodeFile(fileName);
        int width = b.getWidth();
        int height = b.getHeight();
        int isTall = 1;
        float ratio =  ((float)width / height);
        int finalWidth = (int)((float)size * ratio);
        int finalHeight = size;

        if(width > height){
            isTall = 0;
            ratio = ((float) height / width);
            finalWidth = size;
             finalHeight = (int)((float)size * ratio);

         }

        Bitmap out = Bitmap.createScaledBitmap(b, finalWidth, finalHeight, false);

        File file = new File(dir, "resize.png");
        FileOutputStream fOut;
        String base64 = "";
        try {
           fOut = new FileOutputStream(file);
           out.compress(Bitmap.CompressFormat.JPEG, 100, fOut);
           base64 = encodeTobase64(out);
           fOut.flush();
           fOut.close();
           b.recycle();
           out.recycle();
        } catch(Exception el) {

        }
        JSONArray result = new JSONArray();
        JSONObject obj = new JSONObject();
        try{
             ExifInterface exif = new ExifInterface(fileName);

            obj.put("data",  base64);
            obj.put("id",  fileName);
            obj.put("date",  exif.getAttribute(ExifInterface.TAG_DATETIME));
            obj.put("orientation", exif.getAttribute(ExifInterface.TAG_ORIENTATION));
            obj.put("lat", getDegree(exif, 1));
            obj.put("lng", getDegree(exif, 0));
        }catch(Exception e){
        }

        result.put(obj);
        return result;
   }



   public String base64Thumb(String filePath){
        int size = 480;
        File dir=Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM);
        Bitmap b= BitmapFactory.decodeFile(filePath);
        int width = b.getWidth();
         int height = b.getHeight();
         int isTall = 1;
         float ratio =  ((float)width / height);
         int finalWidth = (int)((float)size * ratio);
         int finalHeight = size;

         if(width > height){
             isTall = 0;
             ratio = ((float) height / width);
             finalWidth = size;
             finalHeight = (int)((float)size * ratio);

          }

         Bitmap out = Bitmap.createScaledBitmap(b, finalWidth, finalHeight, false);

        File file = new File(dir, "resize.png");
        FileOutputStream fOut;
        String base64 = "";
        try {
           fOut = new FileOutputStream(file);
           out.compress(Bitmap.CompressFormat.JPEG, 100, fOut);
           base64 = encodeTobase64(out);
           fOut.flush();
           fOut.close();
           b.recycle();
           out.recycle();
        } catch(Exception el) {

        }
        return base64;
   }

     public static String encodeTobase64(Bitmap image)
    {
        Bitmap immagex=image;
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        immagex.compress(Bitmap.CompressFormat.JPEG, 100, baos);
        byte[] b = baos.toByteArray();
        String imageEncoded = Base64.encodeToString(b, Base64.DEFAULT);

        Log.e("LOOK", imageEncoded);
        return imageEncoded;
    }


    private String encodeFileToBase64Binary(String fileName){
        String encodedImage = "";
        try{
           Bitmap bm = BitmapFactory.decodeFile("/path/to/image.jpg");
           ByteArrayOutputStream baos = new ByteArrayOutputStream();
           bm.compress(Bitmap.CompressFormat.JPEG, 100, baos); //bm is the bitmap object
           byte[] b = baos.toByteArray();
            encodedImage = Base64.encodeToString(b, Base64.DEFAULT);
        }catch (Exception e){}
        return encodedImage;
    }




    public double getDegree(ExifInterface exif, int lat) {
        String attrLATITUDE = exif.getAttribute(ExifInterface.TAG_GPS_LATITUDE);
        String attrLATITUDE_REF = exif.getAttribute(ExifInterface.TAG_GPS_LATITUDE_REF);
        String attrLONGITUDE = exif.getAttribute(ExifInterface.TAG_GPS_LONGITUDE);
        String attrLONGITUDE_REF = exif.getAttribute(ExifInterface.TAG_GPS_LONGITUDE_REF);
        double Latitude = 0;
        double Longitude = 0;

        if((attrLATITUDE !=null)
        && (attrLATITUDE_REF !=null)
        && (attrLONGITUDE != null)
        && (attrLONGITUDE_REF !=null))
        {


        if(attrLATITUDE_REF.equals("N")){
            Latitude = convertToDegree(attrLATITUDE);
        }
        else{
            Latitude = 0 - convertToDegree(attrLATITUDE);
        }

        if(attrLONGITUDE_REF.equals("E")){
            Longitude = convertToDegree(attrLONGITUDE);
        }
        else{
            Longitude = 0 - convertToDegree(attrLONGITUDE);
        }

        }
        if(lat == 1)
            return Latitude;
        else
            return Longitude;
    };

    private Double convertToDegree(String stringDMS){
     Float result = null;
     String[] DMS = stringDMS.split(",", 3);

     String[] stringD = DMS[0].split("/", 2);
        Double D0 = new Double(stringD[0]);
        Double D1 = new Double(stringD[1]);
        Double FloatD = D0/D1;

     String[] stringM = DMS[1].split("/", 2);
     Double M0 = new Double(stringM[0]);
     Double M1 = new Double(stringM[1]);
     Double FloatM = M0/M1;

     String[] stringS = DMS[2].split("/", 2);
     Double S0 = new Double(stringS[0]);
     Double S1 = new Double(stringS[1]);
     Double FloatS = S0/S1;

     result = new Float(FloatD + (FloatM/60) + (FloatS/3600));

     return new Double(result);
    }


}