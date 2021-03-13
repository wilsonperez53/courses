//
//  ContentView.swift
//  courses
//
//  Created by Estudiantes on 3/13/21.
//


import SwiftUI

struct Course: Identifiable, Codable {
    let id = UUID()
    let name: String
    let bannerUrl: String
    let price: Int
}

extension Image {
    func data(url:URL) -> Self {
        if let data = try? Data(contentsOf: url) {
            guard let image = UIImage(data: data) else {
                return Image(systemName: "square.fill")
            }
            
            return Image(uiImage: image)
                .resizable()
            

        }
        return self
            .resizable()
    }
}


class CoursesViewModel: ObservableObject {
    @Published var messages = "Message inside the observable object"
    
    @Published var courses: [Course] = [
        .init(name:"Course1",
              bannerUrl:"https://localhost.com",
              price:30
        ),
        .init(name:"Course2",
              bannerUrl:"https://localhost2.com",
              price:50
              )
    ]
    
    func changeMessage(){
        self.messages = "New Message"
    }
    
    func fetchCourses(){
        guard let url = URL(string: "https://api.letsbuildthatapp.com/static/courses.json") else {
                    print("Your API end point is Invalid")
                    return
                }
                let request = URLRequest(url: url)

                // The shared singleton session object.
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let data = data {
                        if let response = try? JSONDecoder().decode([Course].self, from: data) {
                            DispatchQueue.main.async {
                                self.courses = response
                            }
                            return
                        }
                    }
                }.resume()
        
    }
}

struct ContentView: View {
    @ObservedObject var coursesVM = CoursesViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(self.coursesVM.courses){ course in
                    VStack{
                        HStack{
                            Text(course.name)
                            Text(String(course.price))
                        }
                        if let bannerURL = URL(string: course.bannerUrl) {
                            Image(systemName: "square.fill").data(url: bannerURL)
                                .frame(width: 200.0, height: 100.0)
                        }
                        
                    }
                }
            }.navigationBarTitle("Courses")
            .navigationBarItems(
                trailing:Button(
                    action:{
                        print("Fetching json data")
                        self.coursesVM.fetchCourses()
                    },
                    label:{
                        Text("Fetch Courses")
                    }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
