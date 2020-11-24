#pragma once

#include <string>
#include <vector>
#include "message.hpp"
#define String std::string
#define Vector std::vector
void _msg_error(String);
void _msg_info(String);
void _msg_warn(String);
void _msg_debug(String);
void test_conf();
struct build_option{
    String app_name="mkalteriso";
    String install_dir=app_name;
    String iso_label="mkalteriso";
    String iso_publisher="Fascode Network";
    String gpg_key="";
    String out_dir="out";
    String aditional_packages="";
    String work_dir="work";
    String pacman_conf="/etc/pacman.conf";
    String run_cmd="";
    String profile="";
    String airootfs_dir="";
    String isofs_dir="";
    String iso_name="";
    Vector<String> bootmodes;
    String iso_application="";
    String iso_version="";
    String arch="x86_64";
    bool isreleng=false;
    Vector<String> packages_vector;
    Vector<String> aur_packages_vector;
};

void setup(build_option);