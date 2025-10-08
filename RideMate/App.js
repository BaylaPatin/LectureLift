import React, { useState } from 'react';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View, Button, TextInput, Image, TouchableOpacity } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import * as ImagePicker from 'expo-image-picker';

const Stack = createNativeStackNavigator();

function HomeScreen({ navigation })
{
  return (
    <View style={styles.container}>
      <Text style={styles.title}>RideMate</Text>
      <Button title="Profile" onPress={() => navigation.navigate('Profile')}/>
      <StatusBar style="auto" />
    </View>
  );
}

function ProfileScreen()
{
  const [isEditing, setIsEditing] = useState(false);
  const [name, setName] = useState('Anthony Raemsch');
  const [email, setEmail] = useState('araems1@lsu.edu');
  const [image, setImage] = useState(null);

  const pickImage = async() => {
    try
    {
      const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();

      if (!permissionResult.granted)
      {
        alert('Permission to access gallery is required!');
        return;
      }

      const result = await ImagePicker.launchImageLibraryAsync({mediaTypes: ImagePicker.MediaTypeOptions.Images, allowsEditing: true, aspect: [1, 1], quality: 1,});

      if (!result.canceled && result.assets && result.assets.length > 0)
      {
        setImage(result.assets[0].uri);
      }
    }

    catch (error)
    {
      console.error('Image picker error: ', error);
      alert('Something went wrong while picking the image.');
    }
  };

  return (
    <View style={styles.container}>
      {isEditing ? (
        <TouchableOpacity onPress={pickImage}>
        {image ? (
          <Image source={{ uri: image }} style={styles.profileImage}/>
        ) : (
          <View style={[styles.profileImage, styles.placeholder]}>
            <Text style={{ color: '#888' }}>Tap to add photo</Text>
          </View>
          )}
      </TouchableOpacity>
      ): (
        <Image
          source={image ? {uri : image} : null}
          style={[styles.profileImage, !image && styles.placeholder]}
        />
      )}

      {isEditing ? (
        <TextInput
          style={styles.input}
          value={name}
          onChangeText={setName}
        />
      ) : (
          <Text style={styles.text}>Name: {name}</Text>
        
      )}
      
      {isEditing ? (
        <TextInput
          style={styles.input}
          value={email}
          onChangeText={setEmail}
        />
      ) : (
        <Text style={styles.text}>Email: {email}</Text>
      )}

      <Button title={isEditing ? "Save Profile" : 'Edit Profile'}
      onPress={() => 
      {
        if (isEditing)
        {
          alert('Profile saved!');
        }

        setIsEditing(!isEditing);
      }}
      />
    </View>
  );
}

export default function App()
{
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName="Home">
        <Stack.Screen name="Home" component={HomeScreen}/>
        <Stack.Screen name="Profile" component={ProfileScreen}/>
      </Stack.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create
({
  container: 
  {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },

  title:
  {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 20,
  },

  input:
  {
    width: '90%',
    borderWidth: 1,
    borderColor: '#ccc',
    borderRadius: 10,
    padding: 10,
    marginVertical: 8,
  },

  profileImage:
  {
    width: 120,
    height: 120,
    borderRadius: 60,
    marginBottom: 20,
    backgroundColor: '#eee',
  },

  placeholder:
  {
    alignItems: 'center',
    justifyContent: 'center',
  },

  text: { fontSize: 18, marginVertical: 5 },
});